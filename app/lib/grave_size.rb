class GraveSize
  def run
    Figure.includes({ page: :image }).find_each do |figure|
      next if figure.is_a?(Spine) || figure.is_a?(CrossSectionArrow)
      stats = ImageProcessing.getGraveStats(figure, figure.page.image.data)
      figure.perimeter = stats[:arc]
      figure.area = stats[:area]
      figure.save!
    end
  end
end
