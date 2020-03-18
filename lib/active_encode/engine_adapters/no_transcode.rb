# frozen_string_literal: true
require 'fileutils'
require 'nokogiri'
require 'shellwords'
require 'file_locator'

# PassThroughAdapter accepts an input file url and a number of derivative urls in the options
# E.g. `create(input, outputs: [{ label: 'low',  url: 'file:///derivatives/low.mp4' }, { label: 'high', url: 'file:///derivatives/high.mp4' }])`
# This adapter mirrors the ffmpeg adapter but differs in a few ways:
#    1. It starts by copying the derivative files to the work directory
#    2. It runs Mediainfo on the input and output files and skips ffmpeg
#    3. All work is done in the create method so it's status is always completed or failed
module ActiveEncode
  module EngineAdapters
    class NoTranscode
      WORK_DIR = ENV["ENCODE_WORK_DIR"] || "encodes" # Should read from config
      MEDIAINFO_PATH = ENV["MEDIAINFO_PATH"] || "mediainfo"

      def null_encode_object
        params = {}
        params[:id] = 123
        params[:current_operations] = []
        params[:percent_complete] = 0
        params[:errors] = []
        params[:created_at] = Time.now
        params[:updated_at] = Time.now
        # params[:input] = ActiveEncode::Input.new({errors: [], id: '456', url: 'whoawhoawhoa', created_at: Time.now, updated_at: Time.now})

        ae = ActiveEncode::Base.new(params)
        return ae
      end


      def create(input_url, options = {})
        # Decode file uris for ffmpeg (mediainfo works either way)
        # input_url = URI.decode(input_url) if input_url.starts_with? "file:///"

        new_encode = ActiveEncode::Base.new(input_url, options)
        new_encode.id = SecureRandom.uuid
        new_encode.current_operations = []
        new_encode.output = []

        # Create a working directory that holds all output files related to the encode
        # FileUtils.mkdir_p working_path("", new_encode.id)
        # FileUtils.mkdir_p working_path("outputs", new_encode.id)

        # Extract technical metadata from input file
        `#{MEDIAINFO_PATH} --Output=XML --LogFile=#{working_path("input_metadata", new_encode.id)} #{input_url.shellescape}`
        new_encode.input = build_input
        new_encode.input.id = new_encode.id
        new_encode.created_at = new_encode.input.created_at
        new_encode.updated_at = new_encode.input.updated_at

        # if new_encode.input.duration.blank?
        #   new_encode.state = :failed
        #   new_encode.percent_complete = 1

        #   new_encode.errors = if new_encode.input.file_size.blank?
        #                         ["#{input_url} does not exist or is not accessible"]
        #                       else
        #                         ["Error inspecting input: #{input_url}"]
        #                       end

        #   write_errors new_encode
        #   return new_encode
        # end

        # For saving filename to label map used to find the label when building outputs
        # filename_label_hash = {}

        # Copy derivatives to work directory -> no I wont do that
        # options[:outputs].each do |opt|
        #   url = opt[:url]
        #   output_path = working_path("outputs/#{sanitize_base opt[:url]}#{File.extname opt[:url]}", new_encode.id)
        #   FileUtils.cp FileLocator.new(url).location, output_path
        #   filename_label_hash[output_path] = opt[:label]
        # end

        # Write filename-to-label map so we can retrieve them on build_output
        # File.write working_path("filename_label.yml", new_encode.id), filename_label_hash.to_yaml

        new_encode.percent_complete = 1
        new_encode.state = :running
        new_encode.errors = []

        new_encode
      rescue StandardError => e
        new_encode.state = :failed
        new_encode.percent_complete = 1
        new_encode.errors = [e.full_message]
        write_errors new_encode
        return new_encode
      end

    end

    def build_input
      input = ActiveEncode::Input.new
      # metadata = get_tech_metadata(working_path("input_metadata", encode.id))
      input.url = metadata[:url]
      # input.assign_tech_metadata(metadata)
      created_at = Time.now
      input.created_at = created_at
      input.updated_at = created_at

      input
    end


    def find(id, opts = {})
      # encode_class = opts[:cast]
      encode_class = ActiveEncode::Base
      encode = encode_class.new(nil, opts)
      encode.id = id

      encode.created_at = Time.now
      encode.updated_at = Time.now


      encode.input = build_input encode
      encode.input.id = encode.id
      encode.output = []
      encode.current_operations = []

      encode.errors = read_errors(id)
      if encode.errors.present?
        encode.state = :failed
        encode.percent_complete = 1
      elsif cancelled?(id)
        encode.state = :cancelled
        encode.percent_complete = 1
      elsif completed?(id)
        encode.state = :completed
        encode.percent_complete = 100
      else
        encode.output = build_outputs encode
        encode.state = :completed
        encode.percent_complete = 100
      end

      encode
    rescue StandardError => e
      encode.state = :failed
      encode.percent_complete = 1
      encode.errors = [e.full_message]
      write_errors encode
      return encode
    end

    def read_errors(id)
      err_path = working_path("error.log", id)
      error = File.read(err_path) if File.file? err_path
      if error.present?
        [error]
      else
        []
      end
    end

    # Cancel ongoing encode using pid file
    def cancel(id)
      # Check for errors and if not then create cancelled file else raise CancelError?
      if running?(id)
        File.write(working_path("cancelled", id), "")
        find id
      else
        raise CancelError
      end
    end

  end
end
