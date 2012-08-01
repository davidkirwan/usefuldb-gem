require 'yaml'

module UsefulDB

  class Settings
    class << self
  
      attr_accessor :data
      
      # Loads the database from disk
      def load(path)
        begin
          @data = YAML.load(File.open(path))
          
          if @data.class == Array
            puts "Assuming currently installed DB version < 0.0.7 running autoConvert"
            autoConvert()
            save(@data, path)
          elsif @data["version"] != UsefulDB::Version.to_s
            puts "The database version is lower than the latest version running autoUpgrade"
            autoUpgrade()
            save(@data, path)
          else
            #puts "Database version is current"
          end
          
          
          # Debug
          #puts @data.inspect
          
        rescue ArgumentError => e
          exit("Could not parse YAML: #{e.message}")
        end  
      end
      
      
      # Saves the database to disk
      def save(newData, path)
        @data = newData
        f = File.open(path, "w")
        f.write(@data.to_yaml)
        f.close
      end
      
      
      # Converts from db versions < 0.0.6 to the structure introduced in version 0.0.7
      def autoConvert()
        puts "autoConvert Method executing"
        convertedDB = {"version" => UsefulDB::Version.to_s, "db" => @data}
        
        convertedDB["db"].each do |element|
          element["description"] = "nil"
        end
        
        @data = convertedDB
      end
      
      
      # Convert the db from versions lower than the latest version of usefuldb to the latest version
      def autoUpgrade()
        puts "autoUpgrade Method executing"
        @data["version"] = UsefulDB::Version.to_s
      end
      
    end
  end

end