# frozen_string_literal: true
require 'fileutils'
require 'nokogiri'
require 'shellwords'
require 'file_locator'

module ActiveEncode
  module EngineAdapters
    class NoTranscodeAdapter
      INPUT_URL = 'http://no-transcode'.freeze
      INPUT_ID = 'NO-TRANSCODE-INPUT-ID'.freeze
      # ENCODE_ID = 'NO-TRANSCODE'.freeze

      # Return a new ActiveEncode::Base instance, but explicitly does NOT do
      # anything else. The instance should represent an encode job that has just
      # started, but in reality, there is no interaction with any 3rd party
      # system, nor the filesystem.
      def create(_input_url, options = {})
        generate_encode(options[:master_file_id])
      end

      # Returns an ActiveEncode::Base instance that is always completed,
      # because nothing was ever done in the first place. Nothing should be
      # looked up from any 3rd party system, nor from the filesystem.
      def find(id)
        generate_encode state: :completed
      end

      # Returns an ActiveEncode::Base instance that indicates an encode job that
      # has been canceled. In reality, this should never be called because the
      # NoTranscodeAdapter does not produce any sustained encode jobs for which
      # a 'cancel' operation applies. Any and all encode jobs returned
      # from #find are instantly and automatically completed. However, to
      # satisfy active_encode's engine adapter interface, we must implement this
      # method
      def cancel(id)
        generate_encode state: :cancelled
      end

      private

        # Factory method for generating an instance of ActiveEncode::Base.
        # @param state [Symbol] any one of :running, :cancelled, :completed, or
        #   :failed. Default is :running.
        # @param :created_at [Time] Since no real encode job was ever started,
        #   this can just default to Time.now.
        # @param :updated_at [Time] Since no real encode job was ever started,
        #   let alone updated, this can default to anytime after :create_at.
        #   Default is 42 seconds after :created_at.
        def generate_encode(state: :running, master_file_id:)
          ActiveEncode::Base.new(INPUT_URL).tap do |encode|
            # encode.id = ENCODE_ID
            encode.id = SecureRandom.uuid
            encode.global_id = encode.to_global_id.to_s
            encode.master_file_id = master_file_id
            encode.state = state
            encode.input.id = INPUT_ID
            encode.input.created_at = encode.input.updated_at = Time.now
            encode.created_at = Time.now
            encode.updated_at = Time.now + 42
            # Percent complete is either 1 or 100, depending on the state.
            encode.percent_complete = (state == :completed) ? 100 : 1
            # Never any current operations, errors, or output.
            encode.current_operations = []
            encode.output = []
            encode.errors = []
          end
        end
    end
  end
end
