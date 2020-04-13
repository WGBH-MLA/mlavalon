require 'faker'
require 'avalon/controlled_vocabulary'

# Maps Manifest headers to fake data, mostly using Faker gem.
class MarsManifestFaker
  class << self
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
