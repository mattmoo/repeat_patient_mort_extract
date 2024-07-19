## Load your packages, e.g. library(targets).
source("./packages.R")

## Load your R files
lapply(list.files("./R", full.names = TRUE), source)

tar_option_set(
  packages = c("data.table", "lubridate", "healthcodingnz", "comorbidity")
)

tar_plan(
  
  tar_target(
    global_initialisation_vector_raw,
    charToRaw('ngatirangiwewehi')
  ),
  
  tar_target(
    pms_encryption_fn, 
    function(x, key = keyring::key_get("event_encrypt_key", keyring = 'repeat_patient_mort'))
      aes_encrypt_vector(x, global_initialisation_vector_raw, key = key)), 
  
  
  # Paths to data
  tar_target(
    adhb_theatre_event_csv_path,
    '../../data/derived/encrypted_id_source/adhb/19123 Level 8 Theatre Events_Data_IdEncrypted.csv',
    format = 'file'
  ),
  tar_target(
    moh_cohort_csv_path,
    '../../data/derived/encrypted_id_source/moh/rerun_CheckWHO_pus10784_cohort_IdEncrypted.csv',
    format = 'file'
  ),
  tar_target(
    moh_opdiags_csv_path,
    '../../data/derived/encrypted_id_source/moh/rerun_CheckWHO_pus10784_diags_IdEncrypted.csv',
    format = 'file'
  ),
  tar_target(
    moh_event_csv_path,
    '../../data/derived/encrypted_id_source/moh/rerun_CheckWHO_pus10784_events_IdEncrypted.csv',
    format = 'file'
  ),
  
  # Load data
  tar_target(
    adhb_theatre_event_raw_dt,
    data.table::fread(adhb_theatre_event_csv_path)
  ),
  tar_target(
    moh_cohort_raw_dt,
    data.table::fread(moh_cohort_csv_path)
  ),
  tar_target(
    moh_opdiags_raw_dt,
    data.table::fread(moh_opdiags_csv_path)
  ),
  tar_target(
    moh_event_raw_dt,
    data.table::fread(moh_event_csv_path)
  ),
  
  # Define dates
  tar_target(
    min_date,
    as_datetime("2004-07-01")
  ),
  tar_target(
    max_date,
    as_datetime("2014-01-01") - seconds(1)
  ),
  
  # Clean data
  tar_target(
    adhb_theatre_event_dt,
    clean_adhb_theatre_event_dt(
      adhb_theatre_event_raw_dt
    )
  ),
  tar_target(
    moh_cohort_dt,
    clean_moh_cohort_dt(
      moh_cohort_raw_dt
    )
  ),
  tar_target(
    moh_event_dt,
    clean_moh_event_dt(
      moh_event_raw_dt
    )
  ),
  # Clean and separate diagnoses and operations
  tar_target(
    moh_diags_dt,
    extract_moh_diags_dt(
      moh_opdiags_raw_dt,
      moh_event_dt
    )
  ),
  tar_target(
    moh_op_dt,
    extract_moh_op_dt(
      moh_opdiags_raw_dt,
      moh_event_dt
    )
  ),
  
  # Generate a table with a row for each combination of admission ID and
  # operation date.
  tar_target(
    moh_event_opdate_dt,
    generate_event_opdate_dt(
      moh_event_dt,
      moh_op_dt)
  ), 
  
  # Calculate comorbidity scores
  tar_target(
    comorbidity_score_dt,
    generate_comorbidity_score_dt(
      moh_diags_dt
    )
  ),
  # Pull out anaesthetics.
  # Get all anaesthetics with ASA etc.
  tar_target(
    anaesthetic_dt,
    generate_anaesthetic_dt(moh_op_dt)
  ),
  # Get anaesthetics per event/opdate
  tar_target(
    anaesthetic_event_opdate_dt,
    generate_anaesthetic_event_opdate_dt(anaesthetic_dt)
  ), 
  
  # Get surgeries, using clinical severity table_
  tar_target(
    surgery_dt, 
    generate_surgery_dt(moh_op_dt)
  ), 
  tar_target(
    surgery_event_opdate_dt,
    generate_surgery_event_opdate_dt(surgery_dt)
  ),
  
  # Table for analysis.
  tar_target(
    repeat_patient_mort_dt,
    generate_repeat_patient_mort_dt(
      adhb_theatre_event_dt,
      moh_event_opdate_dt,
      moh_cohort_dt,
      moh_event_dt,
      comorbidity_score_dt,
      anaesthetic_event_opdate_dt,
      surgery_event_opdate_dt,
      pms_encryption_fn,
      min_date,
      max_date
    )
  ),
  
  # Output
  tar_target(
    repeat_patient_mort_dt_rds_file,
    saveRDS_filename(
      obj = repeat_patient_mort_dt,
      filename = 'repeat_patient_mort_dt.rds',
      dir = "../../output"
    )
  )

)
