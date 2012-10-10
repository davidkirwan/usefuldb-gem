require 'rubygems'
require 'usefuldb/settings'
require 'usefuldb/utilities'
require 'usefuldb/exceptions'
require 'usefuldb/gui'
require 'usefuldb/version'
require 'fileutils'
require 'logger'

module UsefulDB
  class << self
        
    def add(hash, log)
      UsefulDB::UsefulUtils.add(hash, log)
    end
  
    def count(log)
      UsefulDB::UsefulUtils.count(log)
    end
    
    def remove(key, log)
      UsefulDB::UsefulUtils.remove(key, log)
    end
    
    def dbSave(log)
      UsefulDB::UsefulUtils.dbSave(log)
    end
    
    def dbLoad(log)
      UsefulDB::UsefulUtils.dbLoad(log)
    end
    
    def search(args, log)
      return UsefulDB::UsefulUtils.search(args, log)
    end
    
    def setup(log)
      UsefulDB::UsefulUtils.setup(log)
    end

  end
end
