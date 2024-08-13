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
    image = ImageProcessing.extractFigure(skeleton, skeleton.page.image.data.download)
    io = StringIO.new(image)
    file = HTTP::FormData::File.new io, filename: "skeleton.jpg"
    response = HTTP.post("http://127.0.0.1:8080/skeleton-orientation", form: {
      image: file
    })

    response.parse["predictions"]
  end
end
