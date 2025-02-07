class SkeletonAngles
  def run(figures = nil)
    Skeleton.transaction do
      figures ||= Skeleton.includes({page: :image})
      figures.each do |skeleton|
        prediction_result = skeleton_angle(arrow)
        cos, sin = prediction_result
        skeleton.angle = GraveAngles.convert_angle_result(cos: cos, sin: sin)
        skeleton.save!
      end
    end
    nil
  end

  def skeleton_angle(skeleton)
    image = MinOpenCV.extractFigure(skeleton, skeleton.page.image.data)
    io = StringIO.new(image)
    file = HTTP::FormData::File.new io, filename: "skeleton.jpg"
    response = HTTP.post("#{ENV["ML_SERVICE_URL"]}/skeleton-orientation", form: {
      image: file
    })

    response.parse["predictions"]
  end
end
