#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param adhb_theatre_event_dt
#' @param moh_event_opdate_dt
#' @param moh_cohort_dt
#' @param moh_event_dt
#' @param comorbidity_score_dt
#' @param anaesthetic_event_opdate_dt
#' @param surgery_event_opdate_dt
#' @param pms_encryption_fn
#' @param min_date
#' @param max_date
#' @return
#' @author mattmoo
#' @export
generate_repeat_patient_mort_dt <- function(adhb_theatre_event_dt,
                                            moh_event_opdate_dt,
                                            moh_cohort_dt,
                                            moh_event_dt,
                                            comorbidity_score_dt,
                                            anaesthetic_event_opdate_dt,
                                            surgery_event_opdate_dt,
                                            pms_encryption_fn,
                                            min_date,
                                            max_date) {
  
  
  
  repeat_patient_mort_dt = copy(adhb_theatre_event_dt)
  
  # Attach MOH ID
  repeat_patient_mort_dt[, PMS_THEATRE_DATE := as.Date(PMS_THEATRE_DATETIME)]
  repeat_patient_mort_dt = merge(
    repeat_patient_mort_dt,
    moh_event_opdate_dt,
    by.x = c('PMS_UNIQUE_IDENTIFIER', 'AGENCY', 'PMS_THEATRE_DATE'),
    by.y = c('PMS_UNIQUE_IDENTIFIER', 'AGENCY', 'OP_ACDTE'),
    all.x = TRUE
  )
  
  # Attach MOH event info
  repeat_patient_mort_dt = merge(
    repeat_patient_mort_dt,
    moh_event_dt[, .(MOH_EVENT_ID, MOH_PRIM_HCU, GENDER, ADM_TYPE)],
    by = c('MOH_EVENT_ID'),
    all.x = TRUE
  )
  
  # Attach MOH patient info
  repeat_patient_mort_dt = merge(
    repeat_patient_mort_dt,
    moh_cohort_dt[, .(MOH_NHI, DOB, DOD)],
    by.x = 'PMS_NHI',
    by.y = 'MOH_NHI',
    all.x = TRUE
  )
  
  # Attach comorbidity score
  repeat_patient_mort_dt = merge(
    repeat_patient_mort_dt,
    comorbidity_score_dt[map %ilike% 'm3', .(MOH_EVENT_ID, M3_INDEX = score)],
    by = c('MOH_EVENT_ID'),
    all.x = TRUE
  )
  
  # Attach anaesthetic event
  repeat_patient_mort_dt = merge(
    repeat_patient_mort_dt,
    anaesthetic_event_opdate_dt[, .(
      MOH_EVENT_ID,
      PMS_THEATRE_DATE = OP_ACDTE,
      ASA_PHYSICAL_STATUS = asa_physical_status_max,
      ASA_ACUITY = ifelse(n_asa_acute > 0, yes = 'Acute', no = 'Not acute')
    )],
    by = c('MOH_EVENT_ID', 'PMS_THEATRE_DATE'),
    all.x = TRUE
  )
  
  # Attach surgery data
  repeat_patient_mort_dt = merge(
    repeat_patient_mort_dt,
    surgery_event_opdate_dt[, .(
      CLIN_SYS = '12',
      MOH_EVENT_ID,
      PMS_THEATRE_DATE = OP_ACDTE,
      CLINICAL_SEVERITY = clinical_severity_max,
      CLIN_CD = op_code_priority
    )],
    by = c('MOH_EVENT_ID', 'PMS_THEATRE_DATE'),
    all.x = TRUE
  )
  
  # Attach operation definitions
  repeat_patient_mort_dt = merge(
    repeat_patient_mort_dt,
    healthcodingnz::clinical.code.dt[, .(CLIN_SYS, CLIN_CD, CLINICAL_CODE_DESCRIPTION, BLOCK, CHAPTER)],
    by = c('CLIN_SYS', 'CLIN_CD'),
    all.x = TRUE
  )
  repeat_patient_mort_dt = merge(
    repeat_patient_mort_dt, 
    healthcodingnz::clinical.code.block.dt[, .(CLIN_SYS,
                                               BLOCK,
                                               BLOCK_SHORT_DESCRIPTION)],
    by = c('CLIN_SYS', 'BLOCK'),
    all.x = TRUE
  )
  repeat_patient_mort_dt = merge(
    repeat_patient_mort_dt,
    healthcodingnz::clinical.code.chapter.achi.dt[, .(CLIN_SYS, CHAPTER, CHAPTER_DESCRIPTION)],
    by = c('CLIN_SYS', 'CHAPTER'),
    all.x = TRUE
  )
  
  repeat_patient_mort_dt[, PMS_UNIQUE_IDENTIFIER := pms_encryption_fn(as.character(PMS_UNIQUE_IDENTIFIER))]
  repeat_patient_mort_dt[, PMS_THEATRE_EVENT_ID := pms_encryption_fn(as.character(PMS_THEATRE_EVENT_ID))]
  repeat_patient_mort_dt[, MOH_EVENT_ID := pms_encryption_fn(as.character(MOH_EVENT_ID))]
  
  repeat_patient_mort_dt = repeat_patient_mort_dt[PMS_THEATRE_DATE >= min_date & PMS_THEATRE_DATE <= max_date, .(
    PMS_UNIQUE_IDENTIFIER,
    PMS_THEATRE_EVENT_ID,
    PMS_THEATRE_DATE,
    MOH_EVENT_ID,
    # MOH_NHI = MOH_PRIM_HCU,
    PMS_NHI,
    DOD,
    GENDER,
    ADM_TYPE,
    AGE_YEARS = floor(as.numeric(difftime(PMS_THEATRE_DATE, DOB, units = 'days'))/365.25),
    M3_INDEX,
    ASA_PHYSICAL_STATUS,
    ASA_ACUITY,
    CLINICAL_SEVERITY,
    CLIN_CD,
    BLOCK,
    CHAPTER,
    CLINICAL_CODE_DESCRIPTION,
    BLOCK_SHORT_DESCRIPTION,
    CHAPTER_DESCRIPTION
  )]
  
  return(repeat_patient_mort_dt)

}
