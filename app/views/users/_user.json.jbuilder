json.extract! user, :id, :email, :code_hash, :name, :created_at, :updated_at
json.url user_url(user, format: :json)
