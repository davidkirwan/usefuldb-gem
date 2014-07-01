require 'rubygems'
require 'test/unit'
require 'fileutils'
require 'usefuldb'
require 'logger'

ENV['RACK_ENV'] = 'test'

log = nil

#####################################################
def addColour(text, colour_code)
  "\e[#{colour_code}m#{text}\e[0m"
end

def red(text); addColour(text, 31); end
def green(text); addColour(text, 32); end
def yellow(text); addColour(text, 33); end
def blue(text); addColour(text, 34); end
#####################################################




class UsefulDBTest < Test::Unit::TestCase
  
  attr_accessor :log
  
  def setup
  
    if @log == nil
      @log = log = Logger.new(STDOUT)
      @log.level = Logger::INFO
    end
    
    UsefulDB::dbLoad(@log)
  end

  def teardown
    # Do nothing
  end


  # Test to check adding of entries to the database
  def test_add
    @log.info "Executing test: test_add"
  
    startingCount = UsefulDB.count(@log)
    @log.info "The number of starting database entries: " + startingCount.to_s
  
    begin
      @log.info "Test to check adding an element to the database succeeds"
      entry1 = {"tag" => ["testing", "the", "database", "dbtest"], "value" => "dbtest", "description" => "dbtest"}
      @log.info "Create a new entry:" + entry1.inspect
      UsefulDB.add(entry1, @log)
      @log.info "Adding element to the database"
      
      @log.info "Check the total number of entries in the DB was increased by one " +
      assert_equal(startingCount + 1, UsefulDB.count(@log)).to_s      
      
      @log.info "Test to check adding duplicate element to the DB fails"
      entry2 = {"tag" => ["install", "rubygems", "website", "usefuldb"], "value" => "http://rubygems.org/usefuldb", "description" => "Website URL for the usefuldb gem"}
      @log.info "Create a new entry: " + entry2.inspect
      UsefulDB.add(entry2, @log)
      
    rescue UsefulDB::EmptyDB => e
      assert(false, red(e.message))
    rescue UsefulDB::EntryInDB => e
      @log.info e.message + " this is expected"
    end
    
    tempCount = startingCount + 1
    @log.info "Check the total number of entries in the DB is still #{tempCount} " +
    assert_equal(startingCount + 1, UsefulDB.count(@log)).to_s   
    
    begin
      @log.info "Write the DB structure back to disk and then reload"
      UsefulDB.dbSave(@log)
      UsefulDB.dbLoad(@log)
      
      @log.info "Check the total number of entries in the DB is still #{tempCount} " +
      assert_equal(startingCount + 1, UsefulDB.count(@log)).to_s
      
      @log.info "Deleting this test entry from the database"
      UsefulDB::remove(startingCount, @log)
      
      @log.info "Write the DB structure back to disk and then reload"
      UsefulDB.dbSave(@log)
      UsefulDB.dbLoad(@log)
      
      @log.info "Check the total number of entries in the DB is back to #{startingCount} " +
      assert_equal(startingCount, UsefulDB.count(@log)).to_s
    rescue UsefulDB::EmptyDB => e
      assert(false, red(e.message))
    end 
        
    @log.info "test_add passed"
  end


end
