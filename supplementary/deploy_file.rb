ips = [
  "134.93.167.20",
  "134.93.167.120",
  "134.93.167.123",
  "134.93.167.116",
  "134.93.167.126",
  "134.93.167.127",
  "134.93.167.110",
  "134.93.167.124",
  "134.93.167.122",
  "134.93.167.128",
  "134.93.167.117",
  "134.93.167.17",
  "134.93.167.125"
]

ips.each do |ip|
  cmd = "scp \"#{ARGV[0]}\" \"#{ARGV[1]}\"".gsub("ip", "comove@#{ip}")
  `#{cmd}`
end
