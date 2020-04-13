# MarsManifest is a PORO model that uses ActiveModel::Validations to
# encaspsulate validation of individual rows of a MARS export CSV manifest used
# as input for the Avalon Ingest API.
require 'active_model/validations'
require 'active_support/core_ext/module/delegation'

class MarsManifestRow
  include ActiveModel::Validations

  attr_reader :headers, :normalized_headers, :values

  validates_with MarsManifestRowValidator

  delegate :normalize_header, :required_headers, to: MarsManifest

  def initialize(headers:, values:)
    @headers = headers || []
    @values = values || []
    @normalized_headers = headers.map { |header| normalize_header(header) }
  end

  # private

    # def validate_values
    #   values.each_with_index { |value, index| validate_value headers[index], value }
    # end
    #
    # def validate_value(header, value)
    #   MarsManifestRow.validation_methods_for(header).each do |validation_method|
    #     MarsManifestRow.send(validation_method, value)
    #   end
    # end
    #
    # def missing_required_values
    #   @missing_required_values ||= headers.select.with_index do |header, index|
    #     value_required?(header) && value_blank?(values[index])
    #   end
    # end
    #
    # def value_required?(header)
    #   required_headers.include? normalize_header(header)
    # end
    #
    # def value_blank?(value)
    #   value.to_s.strip = ''
    # end

    # def validate_value(value, index)
    #   validate_header_exists_for_value(value, index)
    # end
    #
    # def validate_header_exists_for_value(value, index)
    #   if headers[index].to_s.strip == ''
    #     add_error(:values, "No header found for value '#{value}'")
    #   end
    # end

    # Adds an error message to a field idempotently (because errors.add is not
    # idempotent, and you can end up with a field having duplicate errors).
    # @param field [Symbol] the field name.
    # @param msg [String] the error message
    # def add_error(field, msg)
    #   errors.add(field, msg) unless errors[field].include? msg
    # end
end
