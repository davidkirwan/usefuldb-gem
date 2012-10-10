require 'rubygems'
require 'yaml'

module UsefulDB

  class Settings
    class << self
  
      attr_accessor :data;
      
      # Loads the database from disk
      def load(path, log)
        begin
          @data = YAML.load(File.open(path))
          
          if @data.class == Array
            log.warn "Assuming currently installed DB version < 0.0.7 running autoConvert"
            
            autoConvert(log)
            log.warn "Database conversion successful"
            save(@data, path, log)
            log.debug "Saving the database"
          elsif @data["version"] != UsefulDB::Version.to_s
            log.warn "The database version is lower than the latest version running autoUpgrade"
            
            autoUpgrade(log)
            log.warn "Database upgrade successful"
            save(@data, path, log)
            log.debug "Saving the database"
          else
            log.debug "Database version is current"
          end
          
          log.debug @data.inspect
          
        rescue ArgumentError => e
          exit("Could not parse YAML: #{e.message}")
        end  
      end
      
      
      # Saves the database to disk
      def save(newData, path, log)
        @data = newData
        f = File.open(path, "w")
        f.write(@data.to_yaml)
        f.close
      end
      
      
      # Converts from db versions < 0.0.6 to the structure introduced in version 0.0.7
      def autoConvert(log)
        log.warn "autoConvert Method executing"
        convertedDB = {"version" => UsefulDB::Version.to_s, "db" => @data}
        
        convertedDB["db"].each do |element|
          element["description"] = "nil"
        end
        
        @data = convertedDB
      end
      
      
      # Convert the db from versions lower than the latest version of usefuldb to the latest version
      def autoUpgrade(log)
        log.warn "autoUpgrade Method executing"
        @data["version"] = UsefulDB::Version.to_s
      end
      
    end
  end

end