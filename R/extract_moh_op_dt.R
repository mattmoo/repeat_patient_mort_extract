#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param moh_opdiags_raw_dt
#' @param moh_event_dt
#' @return
#' @author mattmoo
#' @export
extract_moh_op_dt <- function(moh_opdiags_raw_dt, moh_event_dt) {

  moh_op_dt = moh_opdiags_raw_dt[DIAG_TYP == 'O' &
                                   EVENT_ID %in% moh_event_dt$MOH_EVENT_ID, .(
                                     MOH_EVENT_ID = EVENT_ID,
                                     DIAG_SEQ,
                                     DIAG_TYP,
                                     CLIN_SYS = as.character(CLIN_SYS),
                                     CLIN_CD,
                                     OP_ACDTE = lubridate::dmy(OP_ACDTE)
                                   )]
  
  moh_op_dt = merge(
    moh_op_dt,
    healthcodingnz::clinical.code.dt[, .(CLIN_SYS,
                                         CLIN_CD,
                                         CLINICAL_CODE_DESCRIPTION,
                                         BLOCK,
                                         CHAPTER)],
    by = c('CLIN_SYS', 'CLIN_CD'),
    all.x = TRUE
  )
  
  moh_op_dt = merge(
    moh_op_dt, 
    healthcodingnz::clinical.code.block.dt[, .(CLIN_SYS,
                                               BLOCK,
                                               BLOCK_SHORT_DESCRIPTION,
                                               CLINICAL_SEVERITY)],
    by = c('CLIN_SYS', 'BLOCK'),
    all.x = TRUE
  )
  
  return(moh_op_dt)

}
