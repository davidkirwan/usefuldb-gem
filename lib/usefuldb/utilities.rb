require 'rubygems'
require 'usefuldb/exceptions'
require 'logger'

module UsefulDB

  class UsefulUtils
    class << self
    
      attr_accessor :data, :dbpath
      
      #####################################################
      def addColour(text, colour_code)
        "\e[#{colour_code}m#{text}\e[0m"
      end
      
      def red(text); addColour(text, 31); end
      def green(text); addColour(text, 32); end
      def yellow(text); addColour(text, 33); end
      def blue(text); addColour(text, 34); end
      #####################################################
      
      
      # Save the database to disk
      def dbSave(log)
        if @dbpath.nil?
          log.debug @dbpath = File.expand_path(File.dirname(__FILE__) + '/../../resources/db.yaml')
          @dbpath = ENV['HOME'] + "/.usefuldb/db.yaml"
          UsefulDB::Settings.save(@data, @dbpath, log)
        else
          UsefulDB::Settings.save(@data, @dbpath, log)
        end
      end
      
      
      # Load the database from disk
      def dbLoad(log)
        log.debug @dbpath = File.expand_path(File.dirname(__FILE__) + '/../../resources/db.yaml')
        @dbpath = ENV['HOME'] + "/.usefuldb/db.yaml"
        UsefulDB::Settings.load(@dbpath, log)
        @data = UsefulDB::Settings.data
      end
      
      
      # Return the number of elements in the database.
      def count(log)
        if @data["db"].count == 0
          raise EmptyDB, "The DB is currently empty."
        else
          return @data["db"].count
        end
      end
      
      
      # Add an element to the database
      def add(hash, log)
        if @data["db"].include?(hash) then raise EntryInDB, "Entry already in the DB"; else @data["db"] << hash; end    
      end
  
      
      # Remove an element from the database
      def remove(key, log)
        if @data["db"].count == 0
          raise EmptyDB, "You cannot call the remove function on an empty Database!"
        elsif @data["db"].count <= key || key < 0
          raise KeyOutOfBounds, "Key is out of bounds and therefore does not exist in the DB"
        else
          @data["db"].delete_at(key) 
        end
      end
      
      
      # Setup the system for the first time
      def setup(log)
        log.debug "Checking to see if the database is already installed"
        resourceDir = ENV['HOME'] + "/.usefuldb/"
        log.debug resourceDir
        if File.directory?(resourceDir) 
          log.debug "The folder already exists, do nothing"
        else
          log.debug "Creating ~/.usefuldb/ and installing the DB there."
          FileUtils.mkdir(resourceDir)
          dbpath = File.expand_path(File.dirname(__FILE__) + '/../../resources/db.yaml')
          FileUtils.cp(dbpath, resourceDir)
          log.debug "Database copied to ~/.usefuldb/db.yaml"
        end
      end
      
      
      # Search for a tag in the DB
      def search(tag, log)
        msg = "Searching the database for tag: " + tag + "\n"
        
        @data["db"].each do |db|
          if db["tag"].include?(tag)
            msg += "- Tags: " + array_to_s(db["tag"]) + "\n"
            msg += "- Value: " + db["value"] + "\n"
            msg += "- Description: " + db["description"] +"\n##\n"
          end
        end
        return msg
      end
      
      
      # List out all elements in the DB
      def list(log)
        return @data["db"]
      end


      # Convert an Array to a string
      def array_to_s(a)
        msg = ''
        index = 0
        msg += "["
        a.each do |i|
          if index == 0
            msg += "\"" + i + "\""
          else
            msg += ", \"" + i + "\""
          end
          index += 1
        end
        msg += "]"

        return msg
      end


    end
  end

end
