require 'faker'
require 'avalon/controlled_vocabulary'
require 'active_support/core_ext/module/delegation'

# Maps Manifest headers to fake data, mostly using Faker gem.
class MarsManifestFaker
  attr_reader :headers, :rows

  delegate :fake_row_for, :random_headers, to: :class
  delegate :normalize_header, to: MarsManifest

  def initialize(size: nil)
    size ||= rand(2..50)
    @headers = random_headers
    @rows = size.to_i.times.map { fake_row_for(@headers) }
  end

  def to_s
    headers_and_rows_as_strings = [ headers.join(',') ] + rows_as_strings
    headers_and_rows_as_strings.join("\n")
  end

  # Appends header, returns self for method chaining.
  def add_headers(these_headers)
    Array(these_headers).each { |this_header| add_header(this_header) }
    self
  end

  def add_header(new_header)
    headers << normalize_header(new_header)
    self
  end

  def remove_headers(these_headers)
    Array(these_headers).each { |this_header| remove_header(this_header) }
    self
  end

  def remove_header(this_header)
    indexes_to_delete = indexes_of this_header
    headers.reject!.with_index { |_header, index| indexes_to_delete.include? index }
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

    def indexes_of(header)
      headers.map.with_index{ |h, i| i if normalize_header(h) == normalize_header(header) }.compact
    end

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

    # repeats a value by a given number or a random number within a range.
    def repeat(r)
      raise "block expected" unless block_given?
      return Array.new(rand(r)) { yield } if r.is_a? Range
      Array.new(r.to_i) { yield }
    end

    def random_headers
      [
        "Collection Name",
        repeat(0..1) { "Collection Description" },
        "Unit Name",
        repeat(0..1) { "Collection ID" },
        "Title",
        repeat(0..1) { "Date Issued" },
        repeat(0..4) { "Creator" },
        repeat(0..2) { "Alternative Title" },
        repeat(0..4) { "Translated Title" },
        repeat(0..4) { "Uniform Title" },
        repeat(0..1) { "Statement Of Responsibility" },
        repeat(0..1) { "Date Created" },
        repeat(0..1) { "Copyright Date" },
        repeat(0..1) { "Abstract" },
        repeat(0..3) { "Content Type" },
        repeat(0..3) { "Item Type" },
        repeat(0..3) { "Technical Notes" },
        repeat(0..1) { "Format" },
        repeat(0..4) { "Resource Type" },
        repeat(0..3) { "Contributor" },
        repeat(0..3) { "Publisher" },
        repeat(0..3) { "Genre" },
        repeat(0..3) { "Subject" },
        repeat(0..1) { "Related Item Url" },
        repeat(0..3) { "Geographic Subject" },
        repeat(0..3) { "Temporal Subject" },
        repeat(0..3) { "Topical Subject" },
        "Bibliographic Id",
        repeat(0..4) { "Language" },
        repeat(0..1) { "Terms Of Use" },
        repeat(0..1) { "Table Of Contents" },
        repeat(0..1) { "Physical Description" },
        repeat(0..1) { "MLA Barcode" },
        repeat(0..1) { "Media PIM ID" },
        
        repeat(0..3) { "Comment" },
        repeat(1..4) { [
          repeat(0..1) { "File Label" },
          "File Title",
          "Instantiation Label",
          repeat(0..1) { "Instantiation Id" },
          "Instantiation Streaming URL",
          repeat(0..1) { "Instantiation Duration" },
          repeat(0..1) { "Instantiation Mime Type" },
          repeat(0..1) { "Instantiation Audio Bitrate" },
          repeat(0..1) { "Instantiation Audio Codec" },
          repeat(0..1) { "Instantiation Video Bitrate" },
          repeat(0..1) { "Instantiation Video Codec" },
          repeat(0..1) { "Instantiation Width" },
          repeat(0..1) { "Instantiation Height" },
          repeat(0..1) { "File Location" },
          repeat(0..1) { "File Checksum" },
          repeat(0..1) { "File Size" },
          repeat(0..1) { "File Duration" },
          repeat(0..1) { "File Aspect Ratio" },
          repeat(0..1) { "File Frame Size" },
          repeat(0..1) { "File Format" },
          repeat(0..1) { "File Date Digitized" },
          repeat(0..1) { "File Caption Text" },
          repeat(0..1) { "File Caption Type" },
          repeat(0..1) { "File Other Id" },
          repeat(0..1) { "File Comment" },
          repeat(0..1) { "File Thumbnail Offset" },
          repeat(0..1) { "File Poster Offset" }
        ] }
      ].flatten.compact
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
        Avalon::ControlledVocabulary.vocabulary[:units].sample
      when "date issued", "date created", "copyright date", "file date digitized"
        ( Time.now - rand(10000).days ).strftime date_formats.sample
      when "creator", "contributor"
        person
      when "publisher"
        Faker::Book.publisher
      when "genre", "subject", "geographic subject", "temporal subject",
           "topical subject", "item type", "content type"
        topic
      when "statement of responsibility", "terms of use", "technical notes", "file comment",
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
      when "file thumbnail offset", "file poster offset"
        "#{ "%02d" % rand(60) }:#{ "%02d" % rand(60) }"
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
      when "mla barcode"
        Avalon::ControlledVocabulary.vocabulary[:identifier_types].values.sample
      when "media pim id"
        Avalon::ControlledVocabulary.vocabulary[:identifier_types].values.sample
      when "collection id", "format", "resource type", "bibliographic id",
           "table of contents", "file label", "file title", "instantiation label",
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
      [ Faker::Movies::PrincessBride.quote, Faker::Movies::Ghostbusters.quote,
        Faker::Quote.yoda ].sample
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
