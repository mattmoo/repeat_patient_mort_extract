#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param moh_event_dt
#' @param moh_op_dt
#' @return
#' @author mattmoo
#' @export
generate_event_opdate_dt <- function(moh_event_dt, moh_op_dt) {

  moh_event_opdate_dt = merge.data.table(
    x = unique(moh_op_dt[, .(MOH_EVENT_ID, OP_ACDTE)]),
    y = moh_event_dt[, .(MOH_EVENT_ID,
                         PMS_UNIQUE_IDENTIFIER,
                         # ADM_SRC,
                         # ADM_TYPE,
                         # EVENT_TYPE,
                         # END_TYPE,
                         # EVNTLVD,
                         AGENCY
    )],
    # LOS)],
    by = 'MOH_EVENT_ID',
    all.x = TRUE
  )
  
  return(moh_event_opdate_dt)

}
