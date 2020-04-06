class MarsIngestFieldDef

  def initialize(type, ingest_field_name)
    @type = type
    @ingest_field_name = ingest_field_name
  end
  attr_reader :type
  attr_reader :ingest_field_name
end
