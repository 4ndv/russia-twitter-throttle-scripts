require_relative "../config/environment"
require "csv"

Dir.mkdir("data/public") unless File.exists?("data/public")

# Log.limit(1).as_json(only: [:id, :name])

puts ARGV[0]
puts ARGV[1]

start_date = ARGV[0]
end_date = ARGV[1]

start_date.presence || end_date.presence || puts("Specify start and end date") && exit(1)

start_date = Time.find_zone("UTC").parse("#{start_date} 00:00:00")
end_date = Time.find_zone("UTC").parse("#{end_date} 23:59:59")

logs = Log.where('datetime >= ? AND datetime <= ?', start_date, end_date).order(datetime_rounded: :asc, anonymized_ip: :asc, test_result: :asc).group_by { |item| item.datetime.in_time_zone.strftime("%F") }

headers = %i(datetime_rounded anonymized_ip subnet asn as_country as_organization as_organization_iden version test_result control_result control_taco_result)

logs.keys.each do |date|
  puts date

  date_parts = date.split("-")
  ym = date_parts[0..1].join("-")
  day = date_parts[-1]

  folder = "data/public/#{ym}"
  Dir.mkdir(folder) unless File.exists?(folder)

  CSV.open("data/public/#{ym}/#{day}.csv", "w", write_headers: true, headers: headers) do |writer|
    logs[date].each do |log|
      writer << log.values_at(*headers)
    end
  end
end
