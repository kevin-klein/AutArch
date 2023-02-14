namespace :export do
  task spines: :environment do
    CSV.open('spines.csv', 'w') do |csv|
      csv << %w[ID Angle]
      Spine.find_each do |spine|
        grave = spine.grave
        arrow = grave.arrow
        angle = spine.angle_with_arrow(arrow)
        ap angle
        csv << [grave.id, angle]
      end
    end
  end
end
