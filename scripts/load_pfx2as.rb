require_relative "../config/environment"

# Disable sql logging
ActiveRecord::Base.logger = nil

puts "Loading files..."

pfx2as = Dir
          .glob("data/pfx2as/*.pfx2as")
          .map { |file| IO.readlines(file, chomp: true) }
          .flatten
          .uniq

pfx2as.map! do |item|
  line = item.split("\t")

  # When there are multiple announces of same prefix from different ASN, there is
  # multiple records. Only use first one, ignore others
  {
    prefix: "#{line[0]}/#{line[1]}",
    asn: line[2].split("_").first.split(",").first
  }
end

puts "Deleting previous data"

AsPrefix.delete_all

puts "Importing #{pfx2as.size} lines"

chunks = pfx2as.each_slice(1000).to_a

Parallel.each(
  chunks,
  in_processes: 3,
  progress: {
    title: "Importing chunk",
    format: " %a %b\u{15E7}%i %p%% %t %c/%C",
    progress_mark: " ",
    remainder_mark: "\u{FF65}",
  }
) do |chunk|
  BatchImport.import(AsPrefix.table_name, chunk)
end
