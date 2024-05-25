module UnitAccessor
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def with_unit(name, square: false)
      define_method(:"#{name}_with_unit") do
        if scale.present? && scale.meter_ratio&.positive?
          ratio = scale.meter_ratio
          ratio = scale.meter_ratio**2 if square
          return {value: 0, unit: "px"} if send(name).nil?
          return {value: send(name), unit: "px"} if ratio.nil?
          {value: send(name) * ratio, unit: value_unit(square)}
        elsif percentage_scale.present? || (self.class.method_defined?(:grave) && grave.percentage_scale.present?)
          value = send(name)
          if self.class.method_defined?(:grave)
            cm_on_page = grave.page_size.to_f / grave.page.image.width
            real_cm_per_pixel = (cm_on_page / 100.0) * grave.percentage_scale
          else
            cm_on_page = page_size.to_f / page.image.width
            real_cm_per_pixel = (cm_on_page / 100.0) * percentage_scale
          end

          ratio = real_cm_per_pixel
          ratio = real_cm_per_pixel**2 if square
          return {value: 0, unit: "px"} if send(name).nil?
          return {value: send(name), unit: "px"} if real_cm_per_pixel.nil?
          {value: send(name) * ratio, unit: value_unit(square)}
        else
          {value: send(name), unit: "px"}
        end
      end
    end
  end

  def value_unit(square)
    if square
      "&#13217;"
    else
      "m"
    end
  end
end
