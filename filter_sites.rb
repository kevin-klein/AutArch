COUNTRIES = "Albania
Austria
Bulgaria
Channel Islands
Croatia
Czech Repulic
Denmark
Estonia
France
Germany
Greece
Hungary
Italy
Kazakhstan
Latvia
Lithuania
Moldova
Montenegro
Netherlands
North Macedonia
Poland
Portugal
Russia
Serbia
Slovakia
Slovenia
Spain
Sweden
Switzerland
Ukraine
United Kingdom".split("\n")

PRAGUE_LAT = 50.08804
PRAGUE_LON = 14.42076

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
  filtered << CSV.read('v54.1_HO_public.csv', col_sep: "\t", quote_char: nil, headers: true).headers
  CSV.foreach('v54.1_HO_public.csv', col_sep: "\t", quote_char: nil, headers: true) do |row|
    age = row['Date mean in BP in years before 1950 CE [OxCal mu for a direct radiocarbon date, and average of range for a contextual date]'].to_i
    if age < 3500 && age > 1800 && COUNTRIES.include?(row['Political Entity']) && row['Lat.'] != '..' && row['Long.'] != '..'
      if haversine_distance(PRAGUE_LAT, PRAGUE_LON, row['Lat.'].to_f, row['Long.'].to_f) < 2300
        filtered << row
      end
    end
  end
end
