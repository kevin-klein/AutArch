COUNTRIES = "Albania
Austria
Armenia
Belgium
Bosnia-Herzegovina
Belarus
Bulgaria
Channel Islands
Croatia
Czech Republic
Czechia
Czechoslovakia
Denmark
Estonia
Finland
France
Germany
Gernamy
Gibraltar
Greece
Hungary
Italy
Ireland
Isle of Man
Kazakhstan
Latvia
Malta
Morocco
Lithuania
Moldova
Montenegro
Netherlands
Norway
North Macedonia
Poland
Portugal
Romania
Luxembourg
Russia
Serbia
Slovakia
Slovenia
Spain
Sweden
Switzerland
Ukraine
United Kingdom".split("\n")

VIENNA_LAT = 48.2248977
VIENNA_LON = 16.3522951

def haversine_distance(lat1, lon1, lat2, lon2)
  d_lat = (lat2 - lat1) * Math::PI / 180
  d_lon = (lon2 - lon1) * Math::PI / 180

  a = Math.sin(d_lat / 2) *
      Math.sin(d_lat / 2) +
      Math.cos(lat1 * Math::PI / 180) *
      Math.cos(lat2 * Math::PI / 180) *
      Math.sin(d_lon / 2) * Math.sin(d_lon / 2)

  c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
  r = 6371
  c * r
end

CSV.open('filtered.csv', 'w') do |filtered|
  Xlsxtream::Workbook.open('sites.xlsx') do |xlsx|
    xlsx.write_worksheet('filter_countries') do |countries_sheet|
      headers = CSV.read('v54.1_HO_public.csv', col_sep: "\t", quote_char: nil, headers: true).headers
      countries_sheet << headers
      filtered << headers

      CSV.foreach('v54.1_HO_public.csv', col_sep: "\t", quote_char: nil, headers: true) do |row|
        age = row['Date mean in BP in years before 1950 CE [OxCal mu for a direct radiocarbon date, and average of range for a contextual date]'].to_i

        if age < 5450 && age > 3750 && COUNTRIES.include?(row['Political Entity']) && row['Lat.'] != '..' && row['Long.'] != '..'
          countries_sheet << row.to_hash.values
          filtered << row
        end
      end
    end

    xlsx.write_worksheet('filter_age') do |age_sheet|
      headers = CSV.read('v54.1_HO_public.csv', col_sep: "\t", quote_char: nil, headers: true).headers
      age_sheet << headers

      CSV.foreach('v54.1_HO_public.csv', col_sep: "\t", quote_char: nil, headers: true) do |row|
        age = row['Date mean in BP in years before 1950 CE [OxCal mu for a direct radiocarbon date, and average of range for a contextual date]'].to_i

        if age < 5450 && age > 3750 && row['Lat.'] != '..' && row['Long.'] != '..'
          age_sheet << row.to_hash.values
        end
      end
    end
  end
end


# CSV.open('filtered_2300.csv', 'w') do |filtered|
#   filtered << CSV.read('v54.1_HO_public.csv', col_sep: "\t", quote_char: nil, headers: true).headers
#   CSV.foreach('v54.1_HO_public.csv', col_sep: "\t", quote_char: nil, headers: true) do |row|
#     age = row['Date mean in BP in years before 1950 CE [OxCal mu for a direct radiocarbon date, and average of range for a contextual date]'].to_i
#     if age < 5450 && age > 3750 && row['Lat.'] != '..' && row['Long.'] != '..'
#       filtered << row
#     end
#   end
# end
