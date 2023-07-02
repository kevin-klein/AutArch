namespace :analyse do
  def number_with_unit(n)
    return '' if n.nil? || n[:value].nil?

    "#{'%.2f' % n[:value]} #{n[:unit]}"
  end

  def analyze_db(id, db)
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: db.to_s
    )

    date = Date.new(2023, 6, 9)
    processsed_graves = Grave.where(updated_at: (date.at_beginning_of_day..date.end_of_day))
    grave_data = processsed_graves.map do |grave|
      {
        id: grave.id,
        updated_at: grave.updated_at,
        area: number_with_unit(grave.area_with_unit),
        perimeter: number_with_unit(grave.perimeter_with_unit),
        width: number_with_unit(grave.width_with_unit),
        length: number_with_unit(grave.height_with_unit),
        depth: number_with_unit(grave.grave_cross_section&.height_with_unit)
      }
    end

    return if processsed_graves.length == 0
    CSV.open("#{id}.csv", 'wb') do |csv|
      csv << grave_data.first.keys
      grave_data.each do |grave|
        csv << CSV::Row.new(grave.keys, grave.values)
      end
    end
  end

  task experiment: :environment do
    Dir['supplementary/dfg*'].each_with_index do |folder, index|
      folder1 = File.join(folder, 'development.sqlite3')
      if File.exists?(folder1)
        analyze_db("#{index}_0", folder1)
      end

      folder2 = File.join(folder, 'development1.sqlite3')
      if File.exists?(folder2)
        analyze_db("#{index}_1", folder2)
      end
    end
  end
end