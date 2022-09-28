json.extract! publication, :id, :pdf, :author, :title, :created_at, :updated_at
json.url publication_url(publication, format: :json)
