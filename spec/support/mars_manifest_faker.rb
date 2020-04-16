require 'faker'
require 'avalon/controlled_vocabulary'
require 'active_support/core_ext/module/delegation'

# Maps Manifest headers to fake data, mostly using Faker gem.
class MarsManifestFaker
  attr_reader :headers, :rows

  delegate :fake_row_for, :random_headers, to: :class

  def initialize(size: rand(2..50))
    @headers = random_headers
    @rows = size.to_i.times.map { fake_row_for(@headers) }
  end

  def to_s
    headers_and_rows_as_strings = [ headers.join(',') ] + rows_as_strings
    headers_and_rows_as_strings.join("\n")
  end

  # Appends header, returns self for method chaining.
  def append_headers(headers)
    @headers += Array(headers)
    self
  end

  # Sets a value within a given row.
  # @param header [String] the header for which you want to set the value.
  #   Default nil, in which case, it appends the value to the end of the row.
  # @param row_num [Integer, Range] the row number(s) you want to affect.
  #   To affect the first row use: row_num: 0.
  #   To affect all rows use: row_num: (0..-1)
  def set_value(value, header: nil, row_num: 0)
    col_index = headers.index(header) if header
    rows.slice(row_num).each do |row|
      if col_index
        row[col_index] = value
      else
        row << value
      end
    end
    self
  end

  private

    def rows_as_strings
      # Convert the escpaped rows to double quoted strings.
      rows_with_escaped_quotes.map { |row| '"' + row.join('","') + '"' }
    end

    # Escape double quotes by replacing them all with double-double quotes.
    # Sounds weird, but that's the CSV way.
    def rows_with_escaped_quotes
      rows.map do |row|
        row.map { |r| r.to_s.gsub('"', '""') }
      end
    end

  class << self

    def random_headers
      [
        "Collection Name",
        "Collection Description",
        "Unit Name",
        "Collection ID",
        "Title",
        "Date Issued",
        ["Creator"] * rand(1..4),
        ["Alternative Title"] * rand(1..4),
        ["Translated Title"] * rand(1..4),
        ["Uniform Title"] * rand(1..4),
        "Statement Of Responsibility",
        "Date Created",
        "Copyright Date",
        "Abstract",
        ["Note"] * rand(1..4),
        "Format",
        ["Resource Type"] * rand(1..4),
        ["Contributor"] * rand(1..4),
        ["Publisher"] * rand(1..4),
        ["Genre"] * rand(1..4),
        ["Subject"] * rand(1..4),
        ["Related Item Url"] * rand(1..4),
        ["Geographic Subject"] * rand(1..4),
        ["Temporal Subject"] * rand(1..4),
        ["Topical Subject"] * rand(1..4),
        "Bibliographic Id",
        ["Language"] * rand(1..4),
        "Terms Of Use",
        ["Tables Of Content"] * rand(1..4),
        "Physical Description",
        ["Other Identifier", "Other Identifier Type"] * rand(1..4),
        ["Comment"] * rand(1..4),
        [
          "File Label",
          "File Title",
          "Instantiation Label",
          "Instantiation Id",
          "Instantiation Streaming URL",
          "Instantiation Duration",
          "Instantiation Mime Type",
          "Instantiation Audio Bitrate",
          "Instantiation Audio Codec",
          "Instantiation Video Bitrate",
          "Instantiation Video Codec",
          "Instantiation Width",
          "Instantiation Height",
          "File Location",
          "File Checksum",
          "File Size",
          "File Duration",
          "File Aspect Ratio",
          "File Frame Size",
          "File Format",
          "File Date Digitized",
          "File Caption Text",
          "File Caption Type",
          "File Other Id",
          "File Comment"
        ] * rand(1..4)
      ].flatten
    end


    def fake_row_for(headers)
      headers.map { |header| fake_value_for(header) }
    end

    def fake_value_for(header)
      case MarsManifest.normalize_header(header)
      when "collection name", "title", "alternative title", "uniform title",
           "translated title"
        thing_title
      when "collection description", "abstract"
        description
      when "unit name"
        [ Faker::Job.field, Faker::Company.industry ].sample
      when "date issued", "date created", "copyright date", "file date digitized"
        ( Time.now - rand(10000).days ).strftime date_formats.sample
      when "creator", "contributor"
        person
      when "publisher"
        Faker::Book.publisher
      when "genre", "subject", "geographic subject", "temporal subject",
           "topical subject"
        topic
      when "statement of responsibility", "terms of use", "note", "file comment",
           "comment"
        quote
      when "instantiation audio codec"
        # TODO: used controlled vocabulary?
        ["MPEG-4 Audio", "FLAC"].sample
      when "instantiation video codec"
        # TODO: used controlled vocabulary?
        ["MPEG-4", "MPEG-2", "MPEG-1"].sample
      when "physical description"
        Faker::Coffee.notes
      when "instantiation video bitrate"
        "#{ [ 1, 1.5, 2.5, 4, 5, 7.5, 8, 12, 16, 24 ].sample } Mbps"
      when "instantiation audio bitrate"
        "#{ [ 64, 96, 128, 256 ].sample } kbps"
      when "instantiation streaming url", "related item url"
        Faker::Internet.url
      when "file location"
        object_store_location
      when "language"
        # TODO: used controlled vocabulary?
        ["English", "Spanish", "Klingon", "Esperanto", "Igpay Atinlay"].sample
      when "file size"
        # TODO: Add other units if needed.
        rand(10**5..10**8)
      when "file checksum"
        Digest::MD5.hexdigest rand.to_s
      when "other identifier type"
        Avalon::ControlledVocabulary.vocabulary[:identifier_types].values.sample
      when 'collection id', "format", "resource type", "bibliographic id",
           "tables of content", "other identifier",
           "file label", "file title", "instantiation label",
           "instantiation id", "instantiation duration", "instantiation mime type",
           "instantiation width", "instantiation height", "file location",
           "file size", "file duration", "file aspect ratio",
           "file frame size", "file format", "file caption text", "file caption type",
           "file other id"
        "REPLACE WITH REALISTIC VALUE FOR #{header}"
      else
        raise ArgumentError, "No fake value defined for '#{header}'."
      end
    end

    def date_formats
      ['%Y-%m-%d']
    end

    def quote
      [ Faker::Movies::PrincessBride.quote, Faker::Movies::Lebowski.quote,
        Faker::Movies::Ghostbusters.quote, Faker::Quote.yoda
      ].sample
    end

    def person
      [
        Faker::TvShows::Simpsons.character,
        Faker::TvShows::GameOfThrones.character,
        Faker::Movies::Lebowski.character,
        Faker::Movies::StarWars.character,
        Faker::Name.name_with_middle
      ].sample
    end

    def description
      [
        Faker::Company.bs,
        Faker::Quote.most_interesting_man_in_the_world,
        Faker::Quote.robin,
        Faker::Books::Lovecraft.paragraph
      ].sample
    end

    def thing_title
      [
        Faker::Music.album,
        Faker::Coffee.blend_name,
        Faker::Company.name
      ].sample
    end

    # TODO: use controlled vocab?
    def topic
      [
        Faker::Company.bs,
        Faker::Book.genre
      ].sample
    end

    def object_store_location
      "https://fake-object-store.org/#{barcode}/#{barcode}.mp4"
    end

    def barcode
      rand(10000000).to_s
    end
  end
end
