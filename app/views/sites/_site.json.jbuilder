json.extract! site, :id, :lat, :lon, :name, :created_at, :updated_at
json.url site_url(site, format: :json)
