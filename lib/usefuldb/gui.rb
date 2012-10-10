require 'rubygems'
require 'usefuldb/utilities'

module UsefulDB

  class GUI
    class << self
      attr_accessor 
      
      
      # Search the database
      def search(args, log)
        log.debug "Loading the database"
        UsefulDB.dbLoad(log)
        
        log.debug "Launching UsefulDB::UsefulUtils.search"
        args.each {|i| puts "\n" + UsefulDB::UsefulUtils.search(i, log)} 
      end
      
      
      # List entries in the database
      def list(log)
        log.debug "Loading the database"
        UsefulDB.dbLoad(log)
        
        log.debug "Launching UsefulDB::UsefulUtils.list"
        index = 0
        listing = UsefulDB::UsefulUtils.list(log)
        
        listing.each do |i|
          puts "Element: " + index.to_s
          index += 1
          msg = ''
          msg += "- Tags: " + UsefulDB::UsefulUtils.array_to_s(i["tag"]) + "\n"
          puts msg
          puts "- Value: " + i["value"]
          puts "- Description: " + i["description"] + "\n\n##\n" 
        end
        
        log.info "Number of entries in the database is: " + UsefulDB::UsefulUtils.count(log).to_s
      end
      
      
      # Remove an entry from the database
      def remove(log)
        log.info "Printing out the list of database entries\n"
        list(log)
        
        puts "Enter the number of the element from the list above which you want to delete"
        value = STDIN.gets
        log.debug value
                
        begin
          UsefulDB.remove(value.to_i, log)
          log.info "Entry removed"
          UsefulDB.dbSave(log)
          log.info "Saving database"
        rescue KeyOutOfBounds => e
          puts e.message + "\nexiting."
          log.fatal e.message
          exit()
        end
        
      end
      
      
      # Add element to the database
      def add(log)
        UsefulDB.dbLoad(log)
        
        puts "Please enter the comma separated search tags like the following:"
        log.info "eg:\nterm1, term2, term3\n\n"
        
        begin
          tags = ((STDIN.gets).strip).split(', ')
          log.debug tags.inspect          
          
          puts "Please enter the value you wish to store for this database entry:"
          value = (STDIN.gets).strip
          log.debug value
          
          puts "Please enter a description for this entry: "
          description = (STDIN.gets).strip
          log.debug description
          
          entry = {"tag" => tags, "value" => value, "description" => description}
          
          log.info "Storing the following in the database:" 
          log.info "Search tags: " + UsefulDB::UsefulUtils.array_to_s(tags)
          log.info "Entry Value: " + value
          log.info "Description: " + description
              
          UsefulDB.add(entry, log)
          UsefulDB.dbSave(log)
          log.info "Saving database"
          
        rescue Exception => e
          puts e.message
          log.fatal e.message
          exit
        end
        
      end
    
    
    end
  end

end
