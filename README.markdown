Small thing to apply a JSON list of titles and readings of anime to a
Plex database. Includes a JSON file with my data, but can be used with
anything that follows the structure.

More generally reapplies a set of customizations to series in Plex based
on knowing the matching key that your scanner used to identify the
`metadata_items` for series in your Plex database.

Dependencies:

json
json-schema
sqlite3

You can run it by using the following at the command line after
installing the dependencies and placing a copy of your Plex database to
operate on into the same directory as the script:

`ruby -r "./plex_import.rb" -e "PlexImport.run"`

To generate your own data from your database, you can use sqlite's csv
flag:

`sqlite3 -header -csv com.plexapp.plugins.library.db "select guid, title, title_sort from metadata_items where metadata_type = 2;" > out.csv`

You can then turn this into the JSON file the script expects with the
CSV converter:

`ruby -r "./sqlite_csv_to_json.rb" -e "SqliteCsvToJson.run('./out.csv')"`

Dependencies:

csv
json

TODO:

Lots of improvements to make it configurable: taking input from files on
the command line, allowing custom defintions of which columns to export
and import, etc.
