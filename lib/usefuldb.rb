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
      UsefulDB::Utils.add(hash, log)
    end

    def count(log)
      UsefulDB::Utils.count(log)
    end

    def remove(key, log)
      UsefulDB::Utils.remove(key, log)
    end

    def dbSave(log, options={})
      UsefulDB::Utils.dbSave(log, options)
    end

    def dbLoad(log, options={})
      UsefulDB::Utils.dbLoad(log, options)
    end

    def search(args, log)
      return UsefulDB::Utils.search(args, log)
    end

    def setup(log)
      UsefulDB::Utils.setup(log)
    end

  end
end
