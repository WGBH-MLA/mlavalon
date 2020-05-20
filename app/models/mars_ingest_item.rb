require 'json'
require 'uri'

class MarsIngestItem < ActiveRecord::Base
  STATUSES = %w(unprocessed enqueued processing failed succeeded)

  # csv row object
  # attr_accessor :csv_header_array
  # attr_accessor :csv_value_array

  belongs_to :mars_ingest

  delegate :submitter, to: :mars_ingest

  validates :status, inclusion: STATUSES
  validates :row_payload, presence: true
  validate :validate_payload

  after_initialize do |*args|
    # Set default status to initial state of 'unprocessed' ONLY if it doesn't
    # already have a status saved in the DB.
    self.status ||= 'unprocessed'
  end


  private

    # Ensure required payload values are present.
    def validate_payload
      missing_required_fields = required_payload_fields - row_payload.keys
      if missing_required_fields.present?
        errors.add(:row_payload, "Missing required payload field(s): '#{missing_required_fields.join("', '")}'")
      end
    end

    def required_payload_fields
      ['collection_id', 'title', 'fields', 'files']
    end
end
