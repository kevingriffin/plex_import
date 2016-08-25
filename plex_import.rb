require 'json'
require 'json-schema'
require 'sqlite3'

FILE_SCHEMA = {
  "type" => "object",
  "required" => ["entries"],
  "properties" => {
    "entries" => {
      "type" => "array",
      "required" => ["anidb_id", "title", "reading"],
      "properties" => {
        "anidb_id" => {"type" => "string"},
        "title" => {"type" => "string"},
        "reading" => {"type" => "string"}
      }
    }
  }
}

class PlexImport
  def self.run
    entries  = create_entries(parse_file("./anime_list.json"))
    database = Database.new("./com.plexapp.plugins.library.db")

    entries.each do |entry|
      database.execute(*entry.to_update_sql_and_values)
    end
  end

  def self.parse_file(filepath)
    unless File.readable?(filepath)
      raise RuntimeError.new("Can't access JSON file at #{filepath}")
    end

    parsed_file = nil

    File.open(filepath, 'r') do |file|
      parsed_file = JSON.parse(file.read)
    end

    JSON::Validator.validate!(FILE_SCHEMA, parsed_file)

    parsed_file
  end

  def self.create_entries(parsed_file)
    parsed_file.fetch('entries').map do |entry_hash|
      Entry.new(entry_hash.fetch('anidb_id'), entry_hash.fetch('title'), entry_hash.fetch('reading'))
    end
  end

  class Entry
    attr_reader :anidb_id, :title, :reading
    def initialize(anidb_id, title, reading)
      @anidb_id, @title, @reading = anidb_id, title, reading
    end

    # metadata_items has the data we want to update
    # guid is a string with an identifier for the agent
    # along with a URI from the match
    # title and title sort are the columns to update
    # metadata_type distinguishes series from other items
    # like episodes and seasons

    ENTRY_TABLE_NAME   = 'metadata_items'
    IDENTIFIER_COLUMN  = 'guid'
    TITLE_COLUMN       = 'title'
    READING_COLUMN     = 'title_sort'
    AGENT_HEADER       = 'com.plexapp.agents.hama://anidb-'
    METADATA_COLUMN    = 'metadata_type'
    SERIES_METADATA_ID = 2

    def to_update_sql_and_values
      ["UPDATE #{ENTRY_TABLE_NAME} SET #{TITLE_COLUMN} = ?, \
       #{READING_COLUMN} = ? WHERE #{IDENTIFIER_COLUMN} LIKE ? AND #{METADATA_COLUMN} = #{SERIES_METADATA_ID}",
        title, reading, guid]
    end

    private

    def guid
      "%#{AGENT_HEADER}#{anidb_id}%"
    end
  end

  class Database
    def initialize(database_path)
      @database = SQLite3::Database.new(database_path)
    end

    def execute(sql_string, *values)
      @database.execute(sql_string, values)
    end
  end
end

