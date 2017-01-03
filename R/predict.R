select_expr <- function(string, term) {
  string %<>% stringr::str_replace_all(" ", "")
  string %<>% stringr::str_split(pattern = "\\n")
  string <- string[[1]]
  pattern <- stringr::str_c("^", term, "((<-)|=)")
  string <- string[stringr::str_detect(string, pattern)]
  if (!length(string)) error("term '", term, "' is not defined in new_expr")
  if (length(string) > 1) error("term '", term, "' is defined more than once in new_expr")
  string %<>% stringr::str_replace(pattern, "")
  names(string) <- "identity"
  pattern <- "(^\\w+)([(])(.*)([)]$)"
  if (stringr::str_detect(string, pattern)) {
    fun <- stringr::str_replace(string, pattern, "\\1")
    string %<>% stringr::str_replace(pattern, "\\3")
    names(string) <- fun
  }
  check <- parse_string(string) %>% vapply(any_blank, TRUE)
  if (any(check)) error("new_expr is incomplete")
  string
}

replace_names_with_values <- function(string, list) {
  for (i in seq_along(list)) {
    pattern <- names(list)[i]
    pattern %<>% stringr::str_replace_all("(.*)(\\[)(.*)", "\\1\\\\\\2\\3")
    pattern %<>% stringr::str_replace_all("(.*)(\\])(.*)", "\\1\\\\\\2\\3")
    pattern %<>% stringr::str_c("(^|(?<!\\w))", ., "((?!\\w)|$)")
    string %<>% stringr::str_replace_all(pattern, list[i])
  }
  string
}

parse_string <- function(string) {
  string %<>% stringr::str_replace_all("\\s", "")
  string <- stringr::str_split(string, "[+]")[[1]] %>% stringr::str_split("[*]")
  string
}

weight <- function(x) {
  x %<>% parse(text = .)
  if (length(all.vars(x))) return(NA_real_)
  eval(x)
}

weights <- function(x) {
  x %<>% vapply(weight, 1)
  x
}

get_name_weight <- function(x) {
  stopifnot(is.character(x))
  weights <- weights(x)
  if (sum(is.na(weights)) >= 2) error("new_expr must be linear")
  if (!any(is.na(weights))) return(c("all" = prod(weights)))
  if (length(weights) == 1) {
    y <- 1
  } else
    y <- prod(weights, na.rm = TRUE)
  names(y) <- x[is.na(weights)]
  y
}

c_name <- function(x) {
  x[[1]] %<>% stringr::str_c(names(x), .)
  x
}

par_names_indices <- function(estimates) {
  estimates %<>% lapply(dims) %>% lapply(dims_to_dimensions_vector)
  estimates %<>% purrr::lmap(c_name)
  estimates %<>% sort_nlist()
  estimates
}

lincomb_names <- function(analysis) {
  names <- names(analysis$ad_fun$env$last.par.best)
  if (!is.null(analysis$ad_fun$env$random)) names <- names[-analysis$ad_fun$env$random]

  indices <- estimates(analysis) %>% par_names_indices()
  stopifnot(setequal(names, names(indices)))
  indices <- indices[unique(names)]
  indices %<>% unlist()
  indices %<>% unname()
  indices
}

named_estimates <- function(estimates) {
  stopifnot(is_nlist(estimates))
  indices <- par_names_indices(estimates) %>% unlist()
  estimates %<>% unlist()
  names(estimates) <- indices
  estimates
}

lincomb0 <- function(analysis) {
  names <- lincomb_names(analysis)
  lincomb <- rep(0, length(names))
  names(lincomb) <- names
  lincomb
}

calculate_expr <- function(new_expr, data) {
  new_expr %<>% replace_names_with_values(data)
  new_expr %<>% parse_string()
  new_expr %<>% lapply(get_name_weight) %>% unlist()
  new_expr
}

profile_prediction <- function(data, new_expr, analysis, conf_level, fixed, estimates) {

  data %<>% as.list() %>% c(estimates)

  new_expr %<>% calculate_expr(data)

  sum <- sum(new_expr[names(new_expr) == "all"])
  new_expr <- new_expr[names(new_expr) != "all"]

  if (!length(new_expr)) return(data.frame(estimate = sum, lower = sum, upper = sum))

  lincomb <- lincomb0(analysis)

  if (!all(names(new_expr) %in% names(lincomb))) error("unrecognised parameter name")

  lincomb[names(new_expr)] <- new_expr

  new_expr <- stringr::str_c(names(new_expr), " * ", new_expr, collapse = " + ") %>%
    calculate_expr(fixed)

  estimate <- sum(new_expr)

  data <- data.frame(estimate = estimate + sum)

  profile <- TMB::tmbprofile(analysis$ad_fun, lincomb = lincomb, trace = FALSE) %>%
    confint(level = conf_level) %>% as.data.frame()

  data %<>% dplyr::mutate_(
    lower = ~profile$lower + sum,
    upper = ~profile$upper + sum)
  data
}

calculate_predictions <- function(data, new_expr, term) {
  new_expr %<>% parse(text = .)
  vars <- all.vars(new_expr)
  data[vars[!vars %in% names(data)]] <- NA
  data %<>% within(eval(new_expr))
  if (is.null(data[[term]])) error("term '", term, "' is undefined")
  if (!is.vector(data[[term]])) error("term '", term, "' is not a vector")
  data[[term]]
}

#' Predict
#'
#' Calculate predictions.
#'
#' If \code{conf_int = TRUE} then the confidence intervals are calculated by profiling.
#' The profiling only takes uncertainty in the fixed parameters into account.
#' When profiling \code{new_expr} must be linear (the sum of a series of terms)
#' and can only include one function that encompasses the whole expression,
#' i.e., \code{prediction <- exp(bIntercept + bSlope * y)}.
#'
#' @param object The tmb_analysis object.
#' @param new_data The data frame to calculate the predictions for.
#' @inheritParams mbr::predict_data
#' @return The new data with the predictions.
#' @export
predict.tmb_analysis <- function(object, new_data = data_set(object),
                                 new_expr = NULL,
                                 new_values = list(),
                                 term = "prediction",
                                 conf_int = FALSE, conf_level = 0.95,
                                 modify_new_data = NULL,
                                 parallel = getOption("mb.parallel", FALSE),
                                 quick = getOption("mb.quick", FALSE),
                                 quiet = getOption("mb.quiet", TRUE),
                                 beep = getOption("mb.beep", FALSE),
                                 ...) {

  check_data2(new_data)
  check_uniquely_named_list(new_values)
  check_flag(conf_int)
  check_number(conf_level, c(0.5, 0.99))
  check_flag(parallel)
  check_flag(quick)
  check_flag(quiet)
  check_flag(beep)
  check_unused(...)

  if (beep) on.exit(beepr::beep())

  model <- model(object)

  if (is.null(new_expr)) new_expr <- model$new_expr
  check_string(new_expr)

  data <- mbr::modify_new_data(new_data, data2 = data_set(object), model = model,
                               modify_new_data = modify_new_data)

  fixed <- estimates(object)
  random <- estimates(object, "random") %>%
    zero_random_effects(data, model$random_effects)
  report <- estimates(object, "report")
  adreport <- estimates(object, "adreport")

  data %<>% numericize_factors()

  if (!conf_int || quick) {
    data %<>% c(fixed, random, report, adreport)
    data <- data[!names(data) %in% names(new_values)]
    data %<>% c(new_values)
    estimate <- calculate_predictions(data, new_expr, term)
    if (!length(estimate) %in% c(1, nrow(new_data)))
      error("length of term '", term, "' is invalid")
    new_data %<>% dplyr::mutate_(estimate = ~estimate)
    if (quick) {
      new_data %<>% dplyr::mutate_(lower = ~estimate,
                                   upper = ~estimate)
    }
    return(new_data)
  }

  estimates <- c(random, report, adreport)

  fixed %<>% named_estimates() %>% as.list()
  estimates %<>% named_estimates() %>% as.list()

  new_expr %<>% select_expr(term)
  back_transform <- names(new_expr)

  data %<>% as.data.frame()

  data %<>% plyr::adply(1, profile_prediction, new_expr = new_expr,
                        analysis = object, conf_level = conf_level,
                        fixed = fixed, estimates = estimates,
                        .parallel = parallel)

  data %<>% dplyr::select_(~estimate, ~lower, ~upper)
  data[] %<>% purrr::map(eval(parse(text = back_transform)))

  new_data %<>% dplyr::bind_cols(data)
  new_data
}
