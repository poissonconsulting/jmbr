variable_names <- function(jags_model, data, monitor) {
  vars <- variable.names(jags_model)

 vars <- vars[!vars %in% names(data)]
 vars <- vars[grepl(monitor, vars, perl = TRUE)]

 vars %<>% unique() %>% sort()
 vars
}
