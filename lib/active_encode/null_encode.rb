require 'active_encode/base'

module ActiveEncode

  class NullEncode < Base
    INPUT_ID = 'NULL_ENCODE_INPUT_ID'.freeze
    ID = 'NULL_ENCODE_ID'.freeze

    class << self
      def create(*args)
        new(*args).tap do |encode|
          encode.state = :running
          encode.input.tap do |input|
            input.id = NullEncode::INPUT_ID
            input.created_at = input.updated_at = Time.now
          end
          encode.output = []
          encode.percent_complete = 1
        end
      end

      def find(*args)
        new(*args).tap do |encode|
          encode.percent_complete = 100
        end
      end

      def cancel(*args)
        new(*args).tap do |encode|
          encode.state = :cancelled
        end
      end

      def cancelled?
        encode.state == :cancelled
      end
    end

    # Override attr access for @id to just always return the ID constant.
    def id; ID; end

    # Never any current operations.
    def current_operations; []; end

    def errors; []; end
    def created_at; @created_at ||= Time.now; end
    def updated_at; @updated_at ||= created_at; end
  end
end
