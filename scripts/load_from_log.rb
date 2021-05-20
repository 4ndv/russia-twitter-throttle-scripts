require_relative "../config/environment"
require "cgi"

# File must be in data/final.log
# See README on how to prepare data and what it should look like

# Disable sql logging
ActiveRecord::Base.logger = nil

Parallel.each(
  File.readlines("data/final.log"),
  in_processes: 7,
  progress: {
    title: "Importing",
    format: " %a %b\u{15E7}%i %p%% %t %c/%C",
    progress_mark: " ",
    remainder_mark: "\u{FF65}",
  }
) do |line|
  begin
    ip = line.match(/(^.+)\s-\s-/)[1]
    date = line.match(/\[(.*)\]/)[1]
    date = DateTime.parse(date.split(':', 2).join(' '))
    url = line.match(/GET (.*) HTTP/)[1]
    qs = CGI::parse(url.split('?')[-1]).symbolize_keys
    qs.each { |key, val| qs[key] = val&.first }
    ua = line.split('"')[-2]
  rescue
    next
  end

  # Will not be created if invalid (missing any of the fields)
  log = Log.new(
    ip: ip,
    datetime: date,
    test_result: qs[:test],
    control_result: qs[:control],
    control_taco_result: qs[:controlTaco],
    version: qs[:v].presence || 1,
    user_agent: ua.presence || 1
  )

  if log.invalid?
    puts line
    puts [log.errors.to_hash, ip, date, url, qs, ua]
  end

  # It's faster than using AR's "uniqueness" valiation with scope, which
  # creates additional SQL request
  begin
    log.save
  rescue ActiveRecord::RecordNotUnique
    # Do nothing
  end
end

puts "Assigning fields..."

Log.assign_everything!
