# frozen_string_literal: true

require "usefuldb/settings"
require "usefuldb/utilities"
require "usefuldb/exceptions"
require "usefuldb/version"
require "usefuldb/import_export"
require "usefuldb/cli"
require "fileutils"
require "logger"

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

    def dbSave(log, options = {})
      UsefulDB::Utils.dbSave(log, options)
    end

    def dbLoad(log, options = {})
      UsefulDB::Utils.dbLoad(log, options)
    end

    def search(args, log)
      UsefulDB::Utils.search(args, log)
    end

    def setup(log)
      UsefulDB::Utils.setup(log)
    end

    def export(format: :yaml)
      UsefulDB::ImportExport.export_content(UsefulDB::Utils.export_data, format: format)
    end

    def import(data, mode: :merge, log: nil)
      UsefulDB::ImportExport.import!(data, mode: mode, log: log)
    end
  end
end
