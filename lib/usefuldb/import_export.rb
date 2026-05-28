# frozen_string_literal: true

require "fileutils"
require "yaml"
require "usefuldb/exceptions"
require "usefuldb/json_encoder"
require "usefuldb/utilities"
require "usefuldb/version"

module UsefulDB
  class ImportExport
    FORMATS = %i[yaml json].freeze

    class << self
      def detect_format(path, explicit_format = nil)
        return explicit_format.to_sym if explicit_format

        case File.extname(path.to_s).downcase
        when ".json" then :json
        when ".yaml", ".yml" then :yaml
        else
          raise ImportError, "Could not detect format from #{path}. Use --format yaml or --format json."
        end
      end

      def read_source(path)
        if path == "-"
          $stdin.read
        else
          File.read(path)
        end
      end

      def parse_content(content, format)
        case format
        when :yaml
          parse_yaml(content)
        when :json
          parse_json(content)
        else
          raise ImportError, "Unsupported format: #{format}"
        end
      end

      def parse_file(path, format: nil)
        detected_format = path == "-" && format.nil? ? :yaml : detect_format(path, format)
        parse_content(read_source(path), detected_format)
      end

      def export_content(data, format: :yaml)
        case format
        when :yaml
          data.to_yaml
        when :json
          JSONEncoder.generate(data)
        else
          raise ImportError, "Unsupported format: #{format}"
        end
      end

      def write_export(path, content)
        if path == "-"
          print content
        else
          FileUtils.mkdir_p(File.dirname(File.expand_path(path)))
          File.write(path, content)
        end
      end

      def normalize_imported_data(data)
        if data.is_a?(Array)
          data = {
            "version" => UsefulDB::Version.to_s,
            "db" => data
          }
        end

        unless data.is_a?(Hash) && data["db"].is_a?(Array)
          raise ImportError, "Import file must contain a db array"
        end

        {
          "version" => UsefulDB::Version.to_s,
          "db" => data["db"].map { |entry| normalize_entry(entry) }
        }
      end

      def import!(data, mode:, log:)
        normalized = normalize_imported_data(data)
        current = UsefulDB::Utils.data

        case mode
        when :merge
          import_merge(current, normalized)
        when :replace
          import_replace(normalized)
        else
          raise ImportError, "Unsupported import mode: #{mode}"
        end
      end

      private

      def parse_yaml(content)
        YAML.load(content)
      rescue Psych::Exception => e
        raise ImportError, "Could not parse YAML: #{e.message}"
      end

      def parse_json(content)
        require "json"

        JSON.parse(content)
      rescue LoadError
        raise ImportError, "JSON import requires the json gem. Use YAML format or install json."
      rescue JSON::ParserError => e
        raise ImportError, "Could not parse JSON: #{e.message}"
      end

      def normalize_entry(entry)
        unless entry.is_a?(Hash)
          raise ImportError, "Each database entry must be a mapping"
        end

        tags = UsefulDB::Utils.normalize_tags(entry["tag"] || entry[:tag] || [])
        raise ImportError, "Each database entry requires at least one tag" if tags.empty?

        value = (entry["value"] || entry[:value]).to_s
        raise ImportError, "Each database entry requires a value" if value.strip.empty?

        {
          "tag" => tags,
          "value" => value,
          "description" => (entry["description"] || entry[:description]).to_s
        }
      end

      def import_merge(current, normalized)
        added = 0
        skipped = 0

        normalized["db"].each do |entry|
          if current["db"].include?(entry)
            skipped += 1
          else
            current["db"] << entry
            added += 1
          end
        end

        current["version"] = UsefulDB::Version.to_s

        { mode: :merge, added: added, skipped: skipped, total: current["db"].count }
      end

      def import_replace(normalized)
        UsefulDB::Utils.data = normalized

        { mode: :replace, added: normalized["db"].count, skipped: 0, total: normalized["db"].count }
      end
    end
  end
end
