require 'csv'

module MarsIngestService




  class IngestCSV

    def initialize(filename)
      @csv = CSV.read(filename, {headers: true})
      @rows = @csv.map {|r| IngestCSVRow.new(r) }
    end


    def valid?
      @rows.map {|icr| icr.valid? }
    end

  end

  class IngestCSVRow

    def valid?
      
    end
  end




end