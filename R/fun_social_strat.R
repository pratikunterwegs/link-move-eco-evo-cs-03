#' Assign a social strategy
#'
#' @param df The dataframe with agent id and social weights.
#'
#' @return A dataframe with social strategy assigned.
#' @export
#' @import data.table
#'
get_social_strategy <- function(df) {
  assertthat::assert_that(
    all(c("sH", "sN") %in% names(df)),
    msg = "get_social_strat: data does not have social weights"
  )
  data.table::setDT(df)
  df[, social_strat := data.table::fcase(
    (sH > 0 & sN > 0), "agent tracking",
    (sH > 0 & sN < 0), "handler tracking",
    (sH < 0 & sN > 0), "non-handler tracking",
    (sH < 0 & sN < 0), "agent avoiding"
  )][]
}

#' Get functional variation in movement weights.
#'
#' @param df A dataframe with generation, id, and movement weights.
#'
#' @return Nothing. Transforms weights by reference. See data.table.
#' @export
get_functional_variation <- function(df) {
  data.table::setDT(df)

  assertthat::assert_that(
    all(
      c("sA", "sB", "sH", "sN", "gen") %in% colnames(df)
    )
  )

  assertthat::assert_that(
    all(
      c("wA", "wB", "wH", "wN", "gen") %in% colnames(df)
    )
  )

  # transform weights
  df[, c("sA", "sB", "sH", "sN") := lapply(.SD, function(x) {
    x / (abs(sA) + abs(sB) + abs(sH) + abs(sN))
  }),
  .SDcols = c("sA", "sB", "sH", "sN")
  ]

  # transform weights
  df[, c("wA", "wB", "wH", "wN") := lapply(.SD, function(x) {
    x / (abs(wA) + abs(wB) + abs(wH) + abs(wN))
  }),
  .SDcols = c("wA", "wB", "wH", "wN")
  ]
}

#' Importance of social strategy.
#'
#' @param df The dataframe with agent id and social weights.
#'
#' @return A dataframe with social strategy importance.
#' @export
#' @import data.table
#'
get_si_importance <- function(df) {
  assertthat::assert_that(
    all(c("sH", "sN") %in% names(df)),
    msg = "get_social_strat: data does not have social weights"
  )
  data.table::setDT(df)
  get_functional_variation(df)
  df[, si_imp := abs(sH) + abs(sN)]
  df
}