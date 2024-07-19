#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param moh_event_raw_dt
#' @return
#' @author mattmoo
#' @export
clean_moh_event_dt <- function(moh_event_raw_dt) {

  moh_event_dt = moh_event_raw_dt[AGENCY == 1022, .(
    MOH_EVENT_ID = EVENT_ID,
    MOH_PRIM_HCU = PRIM_HCU,
    ADM_TYPE,
    PMS_UNIQUE_IDENTIFIER,
    GENDER,
    AGENCY
  )]
  
  return(moh_event_dt)

}
