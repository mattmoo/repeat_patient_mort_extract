#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param adhb_theatre_event_raw_dt
#' @return
#' @author mattmoo
#' @export
clean_adhb_theatre_event_dt <- function(adhb_theatre_event_raw_dt) {

  adhb_theatre_event_dt = adhb_theatre_event_raw_dt[, .(PMS_UNIQUE_IDENTIFIER = as.character(`Event ID`), 
                                                        PMS_NHI = NHI, 
                                                        PMS_THEATRE_EVENT_ID = `Theatre Event ID`, 
                                                        PMS_THEATRE_DATETIME = lubridate::as_datetime(`Actual Into Theatre Date Time`),
                                                        AGENCY = 1022)]
  
  return(adhb_theatre_event_dt)

}
