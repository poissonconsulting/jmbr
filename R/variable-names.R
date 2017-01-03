variable_names <- function(jags, data, monitor) {
  vars <- variable.names(jags)

 vars <- vars[!vars %in% names(data)]
 vars <- vars[grepl(monitor, vars, perl = TRUE)]

 vars %<>% unique() %>% sort()
 vars
}
