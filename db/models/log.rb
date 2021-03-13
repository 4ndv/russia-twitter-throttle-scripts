class Log < ActiveRecord::Base
  before_create :anonymize_ip

  validates :datetime, presence: true
  validates :version, presence: true
  validates :test_result, presence: true
  validates :control_result, presence: true
  validates :control_taco_result, presence: true

  protected

    def anonymize_ip
      self.anonymized_ip = IpAnonymizer.mask_ip(self.ip)
    end
end
