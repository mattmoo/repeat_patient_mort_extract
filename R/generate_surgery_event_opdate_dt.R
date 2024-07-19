#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param surgery.dt
generate_surgery_event_opdate_dt <- function(surgery.dt) {

  # Could maybe speed this up by putting it in a single query instead of two.
  
  # Some counts for each admission/opdate combo.
  surgery.event.opdate.dt = surgery.dt[!is.na(OP_ACDTE), .SD[, .(
    clinical.severity.max = max(c(CLINICAL_SEVERITY, -Inf), na.rm = TRUE),
    clinical.severity.min = min(c(CLINICAL_SEVERITY, Inf), na.rm = TRUE),
    n.surgeries = .N
    # has.gynae = any(gynae, na.rm = TRUE),
    # has.ob = any(ob, na.rm = TRUE),
    # has.networkz.specialty = any(networkz.specialty, na.rm = TRUE),
    # has.pomrc.code = any(is.pomrc.code, na.rm = TRUE)
  )],
  by = .(MOH_EVENT_ID, OP_ACDTE)]
  
  
  # Try and get an operation for each event/opdate, and disambiguate where there
  # are multiple.
  categories.surgery.event.opdate.dt = surgery.dt[!is.na(OP_ACDTE), .SD[order(-CLINICAL_SEVERITY, DIAG_SEQ), .(
    chapter_code.priority.ambiguous = length(unique(CHAPTER)) > 1L,
    chapter_code.priority = CHAPTER[1L],
    block_code.priority.ambiguous = length(unique(BLOCK)) > 1L,
    block_code.priority = BLOCK[1L],
    op_code.priority.ambiguous = length(unique(CLIN_CD)) > 1L,
    op_code.priority = CLIN_CD[1L]
  )],
  by = .(MOH_EVENT_ID, OP_ACDTE)]
  
  surgery.event.opdate.dt = merge(
    x = surgery.event.opdate.dt,
    y = categories.surgery.event.opdate.dt,
    by = c('MOH_EVENT_ID', 'OP_ACDTE'),
    all.x = TRUE
  )
  
  surgery.event.opdate.dt[is.infinite(clinical.severity.max), clinical.severity.max := NA]
  surgery.event.opdate.dt[is.infinite(clinical.severity.min), clinical.severity.min := NA]
  
  setnames(surgery.event.opdate.dt, names(surgery.event.opdate.dt), stringr::str_replace_all(names(surgery.event.opdate.dt), '\\.', '_'))
  
  return(surgery.event.opdate.dt)
}
