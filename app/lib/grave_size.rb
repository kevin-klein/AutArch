class GraveSize
  def run
    Grave.includes(figure: { page: :image }).find_each do |grave|
      stats = ImageProcessing.getGraveStats(grave.figure, grave.figure.page.image.data)
      grave.arc_length = stats[:arc]
      grave.area = stats[:area]
      grave.save!
    end
  end
end
