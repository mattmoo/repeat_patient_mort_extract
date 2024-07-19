#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param moh_diag_dt
generate_comorbidity_score_dt <- function(moh_diag_dt) {

  
  args_dt = data.table(
    map = c('m3_icd10_am', 'charlson_icd10_am'),
    weights = c('m3', 'quan'),
    assign0 = c(FALSE, FALSE)
    # out_of_hospital_only = c(TRUE, FALSE, TRUE, FALSE)
  )
  
  generate_score = function(score_ind) {
    
    map = args_dt[score_ind, map]
    weights = args_dt[score_ind, weights]
    assign0 = args_dt[score_ind, assign0]
    # out_of_hospital_only = args_dt[score_ind, out_of_hospital_only]
    
    # if (com_scale == 'm3') {
    #   map = 'm3_icd10_am'
    #   weights = 'm3'
    # } else if (com_scale == 'charlson') {
    #   map = 'charlson_icd10_am'
    #   weights = 'quan'
    # }
    
    # if (out_of_hospital_only == TRUE) {
    #   moh_diag_dt = moh_diag_dt[CONDITION_ONSET_CODE == 2]
    # }
    
    comorbidity_obj = comorbidity::comorbidity(x = moh_diag_dt,
                                               id = 'MOH_EVENT_ID',
                                               code = 'CLIN_CD',
                                               map = map,
                                               assign0 = assign0)
    
    score_dt = data.table(
      MOH_EVENT_ID = comorbidity_obj$MOH_EVENT_ID,
      # out_of_hospital_only = out_of_hospital_only,
      map = map,
      weights = weights,
      assign0 = assign0,
      score = comorbidity::score(comorbidity_obj, weights = weights, assign0 = assign0)
    )
    
    return(score_dt)
  }
  
  comorbidity_score_dt = rbindlist(lapply(
    X = args_dt[, .I],
    FUN = generate_score
  ))
  
  return(comorbidity_score_dt)

}
