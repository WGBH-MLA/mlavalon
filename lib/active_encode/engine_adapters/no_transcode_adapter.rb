# frozen_string_literal: true
require 'fileutils'
require 'nokogiri'
require 'shellwords'
require 'file_locator'
require 'active_encode/null_encode'

# PassThroughAdapter accepts an input file url and a number of derivative urls in the options
# E.g. `create(input, outputs: [{ label: 'low',  url: 'file:///derivatives/low.mp4' }, { label: 'high', url: 'file:///derivatives/high.mp4' }])`
# This adapter mirrors the ffmpeg adapter but differs in a few ways:
#    1. It starts by copying the derivative files to the work directory
#    2. It runs Mediainfo on the input and output files and skips ffmpeg
#    3. All work is done in the create method so it's status is always completed or failed
module ActiveEncode
  module EngineAdapters
    class NoTranscodeAdapter
      def create(input_url, options = {})
        NullEncode.create(input_url, options)
      end

      def find(id, opts = {})
        NullEncode.find(id, opts)
      end

      def cancel(id)
        NullEncode.cancel(id)
      end
    end
  end
end
