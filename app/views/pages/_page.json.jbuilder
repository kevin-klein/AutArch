json.extract! page, :id, :publication_id, :number, :image_id, :created_at, :updated_at

json.figures page.figures.to_a.filter { (_1.probability || 1.0) > 0.6 } do |figure|
  json.extract! figure, :id, :x1, :x2, :y1, :y2, :type, :contour
end

json.image do
  json.extract! page.image, :url, :id, :width, :height
  json.href page.image.url
end
