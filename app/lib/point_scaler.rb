class PointScaler
  def initialize(orig_width:, orig_height:, current_width:, current_height:)
    @width_factor = orig_width / current_width.to_f
    @height_factor = orig_height / current_height.to_f

    # ap @width_factor
    # ap @height_factor
    # raise
  end

  def scale(x, y)
    # [x, y]
    [x * @width_factor, y * @height_factor]
  end
end
