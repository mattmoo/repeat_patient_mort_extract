#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param moh.op.dt
generate_surgery_dt <- function(moh_op_dt) {

  surgery_dt = moh_op_dt[!is.na(CLINICAL_SEVERITY)]
  
  surgery_dt[, CLINICAL_SEVERITY := factor(CLINICAL_SEVERITY, levels = c(1,2,3,4,5,999))]
  
  return(surgery_dt)

}
