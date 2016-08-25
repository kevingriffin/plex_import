require 'json'
require 'csv'

class SqliteCsvToJson
  ANIDB_ID_INDEX   = 0
  TITLE_INDEX      = 1
  TITLE_SORT_INDEX = 2

  def self.run(csv_path)
    hash = {entries: []}

    CSV.foreach(csv_path) do |row|
     hash[:entries] << {anidb_id: row[ANIDB_ID_INDEX], title: row[TITLE_INDEX], reading: row[TITLE_SORT_INDEX]}
    end

    File.open('anime_list.json', 'w') do |file|
      file.puts JSON.dump(hash)
    end
  end
end
