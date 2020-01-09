require 'csv_reader'

filename = ARGV[0]
raise 'that aint right' unless filename
CSVReader.new.ingest_csv(filename)
