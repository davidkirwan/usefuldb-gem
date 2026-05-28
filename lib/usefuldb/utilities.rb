# frozen_string_literal: true

require "fileutils"
require "usefuldb/exceptions"
require "logger"

module UsefulDB
  class Utils
    class << self
      attr_accessor :data, :dbpath

      def db_path(options = {})
        if options[:db]
          File.expand_path(options[:db])
        elsif options[:test]
          File.expand_path(File.join(__dir__, "../../resources/db.yaml"))
        else
          File.join(Dir.home, ".usefuldb", "db.yaml")
        end
      end

      def dbSave(log, options = {})
        @dbpath ||= db_path(options)
        FileUtils.mkdir_p(File.dirname(@dbpath))
        UsefulDB::Settings.save(@data, @dbpath, log)
      end

      def dbLoad(log, options = {})
        @dbpath = db_path(options)

        unless File.exist?(@dbpath)
          raise EntryNotFound, "Database not found at #{@dbpath}"
        end

        UsefulDB::Settings.load(@dbpath, log)
        @data = UsefulDB::Settings.data
      end

      def ensure_db!(log, options = {})
        @dbpath = db_path(options)

        if File.exist?(@dbpath)
          dbLoad(log, options)
        else
          @data = {
            "version" => UsefulDB::Version.to_s,
            "db" => []
          }
        end
      end

      def export_data
        @data
      end

      def count(_log)
        @data["db"].count
      end

      def add(hash, _log)
        if @data["db"].include?(hash)
          raise EntryInDB, "Entry already in the DB"
        end

        @data["db"] << hash
      end

      def remove(key, _log)
        if @data["db"].count == 0
          raise EmptyDB, "You cannot call the remove function on an empty Database!"
        elsif key < 0 || key >= @data["db"].count
          raise KeyOutOfBounds, "Entry id #{key} does not exist"
        else
          @data["db"].delete_at(key)
        end
      end

      def setup(log)
        resource_dir = File.join(Dir.home, ".usefuldb")
        log.debug "Checking to see if the database is already installed"

        if File.directory?(resource_dir)
          log.debug "The folder already exists, do nothing"
        else
          log.debug "Creating ~/.usefuldb/ and installing the DB there."
          FileUtils.mkdir(resource_dir)
          seed_path = File.expand_path(File.join(__dir__, "../../resources/db.yaml"))
          FileUtils.cp(seed_path, resource_dir)
          log.debug "Database copied to ~/.usefuldb/db.yaml"
        end
      end

      def entries
        @data["db"].each_with_index.map do |entry, id|
          entry_with_id(id, entry)
        end
      end

      def get_entry(id)
        entry = @data["db"][id]
        raise KeyOutOfBounds, "Entry id #{id} does not exist" if entry.nil?

        entry_with_id(id, entry)
      end

      def search_entries(tags, match: :all)
        tags = normalize_tags(tags)
        return entries if tags.empty?

        @data["db"].each_with_index.filter_map do |entry, id|
          entry_with_id(id, entry) if entry_matches?(entry, tags, match)
        end
      end

      def find_entry_id(tags:, value:)
        normalized_tags = normalize_tags(tags)

        @data["db"].each_with_index do |entry, id|
          if entry["value"] == value && normalize_tags(entry["tag"]) == normalized_tags
            return id
          end
        end

        nil
      end

      def all_tags
        @data["db"].flat_map { |entry| entry["tag"] }.uniq.sort
      end

      def list(_log)
        @data["db"]
      end

      def search(tag, _log)
        search_entries([tag]).map do |entry|
          "- Tags: #{array_to_s(entry['tag'])}\n" \
            "- Value: #{entry['value']}\n" \
            "- Description: #{entry['description']}\n##\n"
        end.join
      end

      def array_to_s(array)
        "[" + array.map { |item| "\"#{item}\"" }.join(", ") + "]"
      end

      def normalize_tags(tags)
        Array(tags).flat_map { |tag| tag.to_s.split(",") }.map(&:strip).reject(&:empty?)
      end

      private

      def entry_with_id(id, entry)
        {
          "id" => id,
          "tag" => entry["tag"],
          "value" => entry["value"],
          "description" => entry["description"]
        }
      end

      def entry_matches?(entry, tags, match)
        tag_strings = entry["tag"].map(&:downcase)
        matched_terms = tags.map do |term|
          needle = term.downcase
          tag_strings.any? { |tag| tag == needle || tag.include?(needle) }
        end

        match == :any ? matched_terms.any? : matched_terms.all?
      end
    end
  end
end
