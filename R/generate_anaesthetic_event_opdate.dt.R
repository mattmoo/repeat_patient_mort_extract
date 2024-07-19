#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param anaesthetic.dt
generate_anaesthetic_event_opdate_dt <- function(anaesthetic_dt) {

  anaesthetic_event_opdate_dt = anaesthetic_dt[!is.na(OP_ACDTE), .SD[, .(
    asa_physical_status_max = max(c(asa_physical_status,-Inf), na_rm = TRUE),
    asa_physical_status_min = min(c(asa_physical_status, Inf), na_rm = TRUE),
    n_ga = sum(anaesthetic_description %ilike% 'general'),
    n_sedation = sum(anaesthetic_description %ilike% 'sedation'),
    n_regional = sum(anaesthetic_description %ilike% 'regional'),
    n_spinal_general = sum(
      anaesthetic_description %ilike% 'neuraxial' &
        !anaesthetic_description %ilike% 'labour'
    ),
    n_spinal_labour = sum(
      anaesthetic_description %ilike% 'neuraxial' &
        anaesthetic_description %ilike% 'labour'
    ),
    n_asa_acute = sum(asa_acuity == 'Acute'),
    n_asa_not_acute = sum(asa_acuity == 'Not acute/not known')
  )],
  by = .(MOH_EVENT_ID, OP_ACDTE)]
  
  anaesthetic_event_opdate_dt[is.infinite(asa_physical_status_max), asa_physical_status_max := NA]
  anaesthetic_event_opdate_dt[is.infinite(asa_physical_status_min), asa_physical_status_min := NA]
  
  

  return(anaesthetic_event_opdate_dt)
}
