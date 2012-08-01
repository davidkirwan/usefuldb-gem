require 'usefuldb/utilities'

module UsefulDB

  class GUI
    class << self
      attr_accessor 
       
      def search(args)
        UsefulDB.dbLoad
        args.each {|i| puts "\n" + UsefulDB::UsefulUtils.search(i)} 
      end
      
      def list
        UsefulDB.dbLoad
        index = 0
        UsefulDB::UsefulUtils.list.each do |i|
          puts "Element: " + index.to_s
          index += 1
          msg = ''
          msg += "- Tags: " + UsefulDB::UsefulUtils.array_to_s(i["tag"]) + "\n"
          puts msg
          puts "- Value: " + i["value"]
          puts "- Description: " + i["description"] + "\n\n##\n" 
        end
      end
      
      
      
      def remove(opts)
        if opts[:v] then puts "in verbose mode\n"; end
        list()
        
        puts "Enter the number of the element from the list above which you want to delete"
        value = STDIN.gets
                
        begin
          UsefulDB.remove(value.to_i, {})
          UsefulDB.dbSave
        rescue KeyOutOfBounds => e
          puts e.message + "\nexiting."
          exit()
        end
        
      end
      
       
      def add(opts)
        UsefulDB.dbLoad
        
        if opts[:v]
          puts "in verbose mode\n"
          puts "Please enter the comma separated search tags like the following:"
          puts "eg:\nterm1, term2, term3\n\n"
        else
          puts "Please enter the comma separated search tags like the following:"
        end
        
        begin
          tags = ((STDIN.gets).strip).split(', ')
                    
          puts "Please enter the value you wish to store for this database entry:"
          value = (STDIN.gets).strip
          
          puts "Please enter a description for this entry: "
          description = (STDIN.gets).strip
          
          entry = {"tag" => tags, "value" => value, "description" => description}
          
          if opts[:v]
            puts "Storing the following in the database:\n" 
            puts "Search tags: " + UsefulDB::UsefulUtils.array_to_s(tags)
            puts "Entry Value: " + value
            puts "Description: " + description
          end
              
          UsefulDB.add(entry, {})
          UsefulDB.dbSave
          
        rescue Exception => e
          puts e.message
          exit
        end
        
      end
    
    
    end
  end

end
