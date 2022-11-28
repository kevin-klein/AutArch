class GraveArcLengths
  def create
    Grave.transaction do
      Grave.includes(figure: { page: :image }).find_each do |grave|
        ap grave.figure
        grave.arc_length = ImageProcessing.getGraveWidth(grave.figure, grave.figure.page.image.data)
        grave.save!
      end
    end
  end
end
