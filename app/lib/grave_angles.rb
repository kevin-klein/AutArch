class GraveAngles

  def assign_arrow_angles
    Arrow.includes(figure: { page: :image }).find_each do |arrow|
      angle = ImageProcessing.getAngle arrow.figure, arrow.figure.page.image.data
      arrow.angle = angle
      arrow.save!
    end
  end

end
