require_relative "../config/environment"
require "json"

# Disable sql logging
ActiveRecord::Base.logger = nil

puts "Loading files..."

file = Dir
        .glob("data/as_organizations/*.jsonl")
        .first

countries_names = items = IO
                    .readlines(file, chomp: true)
                    .map { |json| JSON.parse(json).symbolize_keys }
                    .select { |item| item[:country].present? }
                    .map do |item|
                      [
                        item[:organizationId],
                        {
                          country: item[:country],
                          name: item[:name].presence || item[:organizationId]
                        }
                      ]
                    end
                    .to_h

items = IO
          .readlines(file, chomp: true)
          .map { |json| JSON.parse(json).symbolize_keys }
          .select { |item| item[:asn].present? }
          .map do |item|
            {
              asn: item[:asn],
              name: countries_names[item[:organizationId]].try(:[], :name).presence || item[:name].presence || item[:organizationId],
              organization_iden: item[:organizationId],
              country: countries_names[item[:organizationId]][:country],
              source: item[:source],
              changed_date: item[:changed],
              opaque_iden: item[:opaqueId]
            }
          end

puts "Deleting previous data"

AsOrganization.delete_all

puts "Importing #{items.size} lines"

chunks = items.each_slice(1000).to_a

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
  BatchImport.import(AsOrganization.table_name, chunk)
end
