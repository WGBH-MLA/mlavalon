require 'rails_helper'
require 'mars_manifest_row'

RSpec.describe MarsManifestRow do
  # subject { described_class.new headers: headers, values: values }
  # let(:headers) { sample_headers }
  # let(:values) { sample_values(headers) }

  # def sample_headers(*args)
  #   # MarsManfiestRowFactoryHelper.sample_headers(*args)
  #   MarsManifest.allowed_headers
  # end
  #
  # def sample_values(headers, blank: [])
  #   values = headers.map do |header|
  #     "Sample value for #{header}"
  #   end
  #
  #   # If :blank was passed, turn all of those values to nil.
  #   Array(blank).each do |header|
  #     blank_indexes = headers.map.with_index { |h, index| index if h == header }.compact
  #     blank_indexes.each { |blank_index| values[blank_index] = nil }
  #   end
  #
  #   values
  # end

  describe '#validate' do
    before { subject.validate }

    context 'when a value does not have a header' do
      subject { FactoryBot.build(:mars_manifest_row, add_values: ['some rogue value']) }
      it { is_expected.to have_error_on :values, /some rogue value/ }
    end

    context 'when missing Collection Name' do
      subject { FactoryBot.build(:mars_manifest_row, blank_values: "Collection Name") }
      # let(:values) { sample_values(headers, blank: "Collection Name") }
      it { is_expected.to have_error_on :values, /Collection Name/ }
    end


    # before { subject.validate }
    #
    # context 'with nil headers and nil row_data' do
    #   it { is_expected.to have_errors_on :headers }
    #   it { is_expected.to have_errors_on :row_data }
    # end
    #
    # context 'when value for Collection Name is empty' do
    #   # subject { FactoryBot.build(:mars_manifest_row) }
    #   it { is_expected.to have_errors_on :row_data }
    # end
  end
end
