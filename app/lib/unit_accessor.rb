module UnitAccessor
  def with_unit(name, square: false)
    define_method("#{name}_with_unit") do
      if scale.present? && scale.meter_ratio > 0 && area > 0
        ratio = scale.meter_ratio
        ratio = scale.meter_ratio ** 2 if square
        { value: send(name) * ratio, unit: 'm' }
      else
        { value: send(name), unit: 'px' }
      end
    end
  end
end
