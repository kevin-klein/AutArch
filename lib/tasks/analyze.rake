namespace :analyze do
  def number_with_unit(n)
    return '' if n.nil? || n[:value].nil?

    "#{'%.2f' % n[:value]}"
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

  task analyze_inkscape_csv: :environment do
    baseline_csv = CSV.open(Rails.root.join('supplementary', 'experiment', 'inkscape', 'baseline.csv').to_s, headers: true, header_converters: :symbol).to_a.map(&:to_hash)
    files = [
      '0_1_inkscape.csv',
      '2_0_inkscape.csv',
      '3_0_inkscape.csv',
      '3_1_inkscape.csv',
      '4_0_inkscape.csv',
      '4_1_inkscape.csv',
      '6_0_inkscape.csv',
      '6_1_inkscape.csv',
    ]

    graves_processed = {}

    errors = files.map do |file|
      data = CSV.open(Rails.root.join('supplementary', 'experiment', 'inkscape', file).to_s, headers: true, header_converters: :symbol).to_a.map(&:to_hash)

      grave_count = data.filter { |user| user[:length_px].present? }.count
      graves_processed[file] = grave_count

      combined_data = baseline_csv.zip(data)
      combined_data = combined_data.filter { |base, user| base.present? && user.present? }


      total_error = get_error(combined_data)
      [file, total_error]
    end.to_h

    # CSV.open('inkscape_error.csv', 'wb') do |csv|
    #   csv << %w[User Error]
    #   errors.each do |error|
    #     csv << [error[0], error[1]]
    #   end
    # end

    # CSV.open('inkscape_count.csv', 'wb') do |csv|
    #   csv << %w[User Graves]
    #   graves_processed.each do |processsed|
    #     csv << [processsed[0], processsed[1]]
    #   end
    # end
    puts errors.to_json
  end

  task analyze_comove_csv: :environment do
    base_path = Rails.root.join('supplementary/experiment/comove/baseline.csv').to_s
    baseline_csv = CSV.open(base_path, headers: true, header_converters: :symbol).to_a.map(&:to_hash)
    files = [
      '0_1.csv',
      '2_0.csv',
      '3_0.csv',
      '3_1.csv',
      '4_0.csv',
      '4_1.csv',
      '5_0.csv',
      '5_1.csv',
      '6_0.csv',
      '6_1.csv'
    ]
    graves_processed = {}

    errors = files.map do |file|
      data = CSV.open(Rails.root.join('supplementary', 'experiment', 'comove', file).to_s, headers: true, header_converters: :symbol).to_a.map(&:to_hash)
      combined_data = baseline_csv.zip(data)

      # grave_count = data.count
      # graves_processed[file] = grave_count
      combined_data = combined_data.filter { |base, user| base.present? && user.present? }
      total_error = get_error(combined_data)
      [file, total_error]
    end.to_h
    puts errors.to_json
  end

  def get_error(combined_data)
    combined_data.map do |base, user|
      difference = base.map do |key, _value|
        if %i[id updated_at].include?(key)
          nil
        else
          base_value = base[key].to_f
          user_value = user[key].to_f
          if base_value.zero?
            if user_value.zero?
              0
            else
              1
            end
          else
            diff = base_value - user_value
            diff / base_value
          end
        end
      end.compact.map(&:abs)
      difference.sum(0.0) / difference.size
    end
  end

  task baseline: :environment do
    processsed_graves = Grave.where('id <= 197')
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

    CSV.open('baseline.csv', 'wb') do |csv|
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
