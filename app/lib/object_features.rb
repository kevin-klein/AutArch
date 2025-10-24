module ObjectFeatures
  module_function

  def run(figure)
    features = object_features(figure)
    figure.features = features
    figure.save!
  end

  def object_features(figure)
    image = MinOpenCV.extractFigure(figure, figure.page.image.data)
    io = StringIO.new(image)
    file = HTTP::FormData::File.new io, filename: "object.jpg"
    response = HTTP.post("#{ENV["ML_SERVICE_URL"]}/features", form: {
      image: file
    })

    response.parse["features"].flatten
  end
end
