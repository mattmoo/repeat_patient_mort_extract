#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param moh_cohort_raw_dt
#' @return
#' @author mattmoo
#' @export
clean_moh_cohort_dt <- function(moh_cohort_raw_dt) {

  moh_cohort_dt = moh_cohort_raw_dt[, .(
    MOH_NHI = nhi,
    MOH_PRIM_HCU = PRIM_HCU,
    DOB = lubridate::dmy(date_of_birth),
    DOD = lubridate::dmy(date_of_death)
  )]
  
  return(moh_cohort_dt)

}
