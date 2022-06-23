#' Checks the validity of the `simulation_output` class.
#'
#' @param object Instance of the `simulation_output` class.
#'
#' @return Boolean or errors
#' @export
#'
check_simulation_output <- function(object) {
  errors <- character()
  length_scenario <- length(object@scenario)
  if (length_scenario != 1) {
    msg <- sprintf("scenario is length %i, should be 1.", length_scenario)
    errors <- c(errors, msg)
  }

  if (length(errors) == 0) {
    TRUE
  } else {
    errors
  }
}

#' Defines the `simulation_output` class.
#'
#' @slot parameters list.
#' @slot trait_data list.
#' @slot edge_list data.frame.
#'
#' @export
setClass(
  # name of the class
  Class = "simulation_output",

  # define the types of the class
  slots = c(
    parameters = "list",
    trait_data = "list",
    edge_list = "data.frame"
  ),

  # define the default values of the slots
  prototype = list(
    parameters = list(),
    trait_data = list(),
    edge_list = data.frame()
  ),

  # check validity of class
  validity = check_simulation_output
)

#' Get trait data.
#'
#' @param object A `simulation_output` object.
#'
#' @return A `data.table` object.
#' @export
#'
get_trait_data = function(object) {
    trait_data = object@trait_data
    gens = seq(length(trait_data))
    
    assertthat::assert_that(
      length(trait_data) == length(gens)
    )
    gens = gens[!(sapply(trait_data, is.null))] - 1
    trait_data = trait_data[!(sapply(trait_data, is.null))]
    
    
    trait_data = Map(
        trait_data, gens,
        f = function(df, g) {
            df$gen = g
            df
        }
    )
    trait_data = data.table::rbindlist(trait_data)
    trait_data
}
