json.extract! c14_date, :id, :c14_type, :lab_id, :age_bp, :interval, :material, :calbc_1sigma_max, :calbc_1_sigma_min,
  :calbc_2sigma_max, :calbc_2sigma_min, :date_note, :cal_method, :ref_14c, :created_at, :updated_at
json.url c14_date_url(c14_date, format: :json)
