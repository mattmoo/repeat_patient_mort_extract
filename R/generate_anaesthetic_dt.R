#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param moh_op_dt
generate_anaesthetic_dt <- function(moh_op_dt) {
  
  
  anaesthetic_dt = moh_op_dt[CLINICAL_CODE_DESCRIPTION %like% 'ASA',
                             .(CLIN_CD,
                               CLIN_SYS,
                               MOH_EVENT_ID,
                               OP_ACDTE,
                               CLINICAL_CODE_DESCRIPTION)]
  
  anaesthetic_dt[, anaesthetic_description := stringr::str_remove(string = CLINICAL_CODE_DESCRIPTION,
                                                                  pattern = ', ASA \\d\\d$')]
  
  
  anaesthetic_dt[, asa_physical_status := as.numeric(stringr::str_extract(string = CLINICAL_CODE_DESCRIPTION,
                                                                          pattern = '\\d(?=\\d$)'))]
  anaesthetic_dt[, asa_acuity := as.numeric(stringr::str_extract(string = CLINICAL_CODE_DESCRIPTION,
                                                                 pattern = '\\d$'))]
  anaesthetic_dt[asa_physical_status == 9, asa_physical_status := NA]
  anaesthetic_dt[, asa_physical_status := factor(asa_physical_status,
                                                 levels = c(1, 2, 3, 4, 5, 6),
                                                 ordered = TRUE)]
  anaesthetic_dt[, asa_acuity := factor(
    asa_acuity,
    levels = c(0, 9),
    labels = c('Acute', 'Not acute/not known')
  )]
  
  return(anaesthetic_dt)
  

}
