module UnitAccessor
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def with_unit(name, square: false)
      define_method("#{name}_with_unit") do
        if scale.present? && scale.meter_ratio&.positive?
          ratio = scale.meter_ratio
          ratio = scale.meter_ratio**2 if square
          return { value: send(name), unit: 'px' } if ratio.nil?
          { value: send(name) * ratio, unit: value_unit(square) }
        else
          { value: send(name), unit: 'px' }
        end
      end
    end
  end

  def value_unit(square)
    if square
      '&#13217;'
    else
      'm'
    end
  end
end
