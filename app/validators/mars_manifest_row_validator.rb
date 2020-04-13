require 'active_support/core_ext/module/delegation'

class MarsManifestRowValidator < ActiveModel::Validator
  attr_reader :mars_manifest_row

  delegate :headers, :values, :normalized_headers, :normalize_header, :errors,
           to: :mars_manifest_row

  def validate(mars_manifest_row)
    raise ArgumentError, "#{self.class} only validates MarsManifestRow instances" unless mars_manifest_row.is_a? MarsManifestRow
    @mars_manifest_row = mars_manifest_row
    validate_values
  end

  private

    def validate_values
      values.each_with_index { |value, index| validate_value(value, index) }
    end

    def validate_value(value, index)
      validate_value_has_header(value, index)
      validate_value_format(value, index)
    end

    def validate_value_has_header(value, index)
      if normalized_headers[index].empty?
        errors.add(:values, "No header in column #{index + 1} for value '#{value}'")
      end
    end

    def validate_value_format(value, index)
      validation_methods_for(headers[index]).each do |validation_method|
        send(validation_method, headers[index], value, index)
      end
    end

    def validation_methods_for(header)
      validation_methods[normalize_header(header)] || []
    end

    def validation_methods
      {
        "collection name" => [:presence],
        "unit name" => [:presence],
        "title" => [:presence],
        "file label" => [:presence],
        "file title" => [:presence]
      }
    end

    def presence(header, value, index)
      if value.to_s.strip.empty?
        errors.add(:values, "Value required for #{header} in column #{index}")
      end
    end
end
