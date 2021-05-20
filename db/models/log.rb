class Log < ActiveRecord::Base
  before_create :anonymize_ip

  validates :datetime, presence: true
  validates :version, presence: true
  validates :test_result, presence: true
  validates :control_result, presence: true
  validates :control_taco_result, presence: true

  scope :without_asn, -> { where(asn: nil) }
  scope :throttled, -> { where('test_result < 200 AND control_result > 600') }
  scope :not_throttled, -> { where('test_result > 200 AND control_result > 600') }
  scope :taco_throttled, -> { self.throttled.where('control_taco_result < 200') }

  # Thanks to @darkk for the part of this query!
  def self.assign_asn_and_subnets!(ignore_existing: false)
    ignore = " AND logs.asn IS NULL AND logs.subnet IS NULL" if ignore_existing

    Log.connection.execute <<-SQL
      WITH most_specific_asns AS (
          SELECT ip, prefix, asn FROM (
              SELECT
                  ip,
                  prefix,
                  as_prefixes.asn,
                  MAX(
                    masklen(prefix)
                  ) OVER (PARTITION BY ip) AS most_specific
              FROM logs
              LEFT JOIN as_prefixes ON (prefix >>= ip)
          ) t1
          WHERE prefix IS NULL OR masklen(prefix) = most_specific
      )
      UPDATE logs
      SET asn = most_specific_asns.asn, subnet = most_specific_asns.prefix
      FROM most_specific_asns
      WHERE logs.ip = most_specific_asns.ip#{ignore};
    SQL
  end

  def self.round_time!
    Log.connection.execute <<-SQL
      UPDATE logs
      SET datetime_rounded = date_trunc('hour', datetime) + date_part('minute', datetime)::int / 5 * interval '5 min';
    SQL
  end

  def self.assign_as_data!
    Log.connection.execute <<-SQL
      UPDATE logs
      SET as_organization_iden = as_organizations.organization_iden, as_organization = as_organizations.name, as_country = as_organizations.country
      FROM as_organizations
      WHERE logs.asn = as_organizations.asn;
    SQL
  end

  def self.assign_everything!
    puts "Rounding time"
    self.round_time!
    puts "Assigning ASNs and subnets"
    self.assign_asn_and_subnets!(ignore_existing: false)
    puts "Assigning AS data"
    self.assign_as_data!
  end

  def subnet
    return nil if super.nil?

    "#{super}/#{super.prefix}"
  end

  protected

    def anonymize_ip
      self.anonymized_ip = IpAnonymizer.mask_ip(self.ip)
    end
end
