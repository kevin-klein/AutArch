class SkeletonPosition
  def run(figures = nil)
    SkeletonFigure.transaction do
      figures ||= SkeletonFigure.includes({page: :image})
      figures.each do |skeleton|
        skeleton.deposition_type = deposition_type(skeleton)
        skeleton.save!
      end
    end
    nil
  end

  def deposition_type(skeleton)
    image = MinOpenCV.extractFigure(skeleton, skeleton.page.image.data)
    io = StringIO.new(image)
    file = HTTP::FormData::File.new io, filename: "arrow.jpg"
    response = HTTP.post("#{ENV["ML_SERVICE_URL"]}/skeleton", form: {
      image: file
    })

    response.parse["predictions"]
  end
end
