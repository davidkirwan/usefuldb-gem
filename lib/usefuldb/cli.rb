# frozen_string_literal: true

require "optparse"
require "usefuldb/json_encoder"
require "usefuldb/utilities"

module UsefulDB
  class CLI
    COMMANDS = %w[search list add remove rm show count export import help].freeze
    ImportExport = UsefulDB::ImportExport

    def self.run(argv, log:)
      global, remaining = parse_global_options(argv)
      configure_logger(log, global)

      if remaining.empty?
        print_help
        return 0
      end

      if command?(remaining.first)
        command = remaining.shift

        case command
        when "help"
          print_help(remaining.first)
        when "search"
          run_search(remaining, global, log)
        when "list"
          run_list(remaining, global, log)
        when "add"
          run_add(remaining, global, log)
        when "remove", "rm"
          run_remove(remaining, global, log)
        when "show"
          run_show(remaining, global, log)
        when "count"
          run_count(global, log)
        when "export"
          run_export(remaining, global, log)
        when "import"
          run_import(remaining, global, log)
        end
      else
        unknown = remaining.first
        raise OptionParser::ParseError, "Unknown command: #{unknown}. Use `usefuldb search` to find entries."
      end

      0
    rescue EntryInDB, EmptyDB, KeyOutOfBounds, EntryNotFound, ImportError => e
      warn e.message unless global[:quiet]
      1
    rescue OptionParser::ParseError => e
      warn e.message unless global[:quiet]
      warn "Run `usefuldb help` for usage." unless global[:quiet]
      1
    end

    def self.command?(name)
      COMMANDS.include?(name)
    end

    def self.parse_global_options(argv)
      global = {
        db: nil,
        quiet: false,
        verbose: false
      }
      remaining = argv.dup

      while (arg = remaining.first)
        case arg
        when "--db"
          remaining.shift
          global[:db] = remaining.shift or raise OptionParser::ParseError, "missing argument: --db"
        when "-q", "--quiet"
          remaining.shift
          global[:quiet] = true
        when "-v", "--verbose"
          remaining.shift
          global[:verbose] = true
        when "--version"
          remaining.shift
          puts UsefulDB::Version.to_s
          exit 0
        when "-h", "--help"
          remaining.shift
          print_help
          exit 0
        when "--"
          remaining.shift
          break
        else
          break
        end
      end

      [global, remaining]
    end

    def self.configure_logger(log, global)
      if global[:quiet]
        log.level = Logger::ERROR
      elsif global[:verbose]
        log.level = Logger::DEBUG
      else
        log.level = Logger::ERROR
      end
    end

    def self.partition_argv(argv, value_flags: [])
      options_argv = []
      positional = []
      index = 0

      while index < argv.length
        token = argv[index]

        if token == "--"
          positional.concat(argv[(index + 1)..])
          break
        elsif token == "-"
          positional << token
          index += 1
        elsif token.start_with?("-")
          options_argv << token
          index += 1

          if value_flags.include?(token) && index < argv.length && !argv[index].start_with?("-")
            options_argv << argv[index]
            index += 1
          end
        else
          positional << token
          index += 1
        end
      end

      [options_argv, positional]
    end

    def self.load_options(global)
      options = {}
      options[:db] = global[:db] if global[:db]
      options
    end

    def self.load_db!(log, global)
      UsefulDB.setup(log) unless global[:db]
      UsefulDB.dbLoad(log, load_options(global))
    end

    def self.run_search(argv, global, log)
      options = {
        match: :all,
        format: :human,
        ids: false
      }

      parser = OptionParser.new do |opts|
        opts.banner = "Usage: usefuldb search [options] [tags...]"
        opts.on("--any", "Match entries with any tag (OR)") { options[:match] = :any }
        opts.on("--json", "Print results as JSON") { options[:format] = :json }
        opts.on("--value-only", "Print only entry values") { options[:format] = :value_only }
        opts.on("--ids", "Include entry ids in human output") { options[:ids] = true }
        opts.on("-h", "--help", "Show this help") do
          puts opts
          exit 0
        end
      end

      option_argv, tags = partition_argv(argv)
      parser.parse!(option_argv)

      load_db!(log, global)
      results = UsefulDB::Utils.search_entries(tags, match: options[:match])
      print_entries(results, format: options[:format], ids: options[:ids])
    end

    def self.run_list(argv, global, log)
      options = {
        format: :human,
        tags_only: false
      }

      parser = OptionParser.new do |opts|
        opts.banner = "Usage: usefuldb list [options]"
        opts.on("--json", "Print results as JSON") { options[:format] = :json }
        opts.on("--tags-only", "Print unique tags") { options[:tags_only] = true }
        opts.on("-h", "--help", "Show this help") do
          puts opts
          exit 0
        end
      end

      parser.order!(argv)

      load_db!(log, global)

      if options[:tags_only]
        tags = UsefulDB::Utils.all_tags
        if options[:format] == :json
          puts UsefulDB::JSONEncoder.generate(tags)
        else
          tags.each { |tag| puts tag }
        end
        return
      end

      print_entries(UsefulDB::Utils.entries, format: options[:format], ids: true)
    end

    def self.run_add(argv, global, log)
      options = {
        tags: nil,
        value: nil,
        description: nil
      }

      parser = OptionParser.new do |opts|
        opts.banner = "Usage: usefuldb add [options]"
        opts.on("--tags TAGS", "Comma-separated search tags") { |value| options[:tags] = value }
        opts.on("--value VALUE", "Stored command, URL, or text") { |value| options[:value] = value }
        opts.on("--description TEXT", "Entry description") { |value| options[:description] = value }
        opts.on("-h", "--help", "Show this help") do
          puts opts
          exit 0
        end
      end

      parser.order!(argv)

      load_db!(log, global)

      tags = options[:tags]
      value = options[:value]
      description = options[:description]

      if tags.nil?
        $stdout.print "Tags (comma-separated): "
        tags = $stdin.gets.to_s.strip
      end

      if value.nil?
        $stdout.print "Value: "
        value = $stdin.gets.to_s.strip
      end

      if description.nil? && $stdin.tty?
        $stdout.print "Description (optional): "
        description = $stdin.gets.to_s.strip
      end

      normalized_tags = UsefulDB::Utils.normalize_tags(tags)
      raise OptionParser::ParseError, "At least one tag is required" if normalized_tags.empty?
      raise OptionParser::ParseError, "Value is required" if value.to_s.strip.empty?

      entry = {
        "tag" => normalized_tags,
        "value" => value.strip,
        "description" => description.to_s
      }

      UsefulDB.add(entry, log)
      UsefulDB.dbSave(log, load_options(global))

      new_id = UsefulDB::Utils.count(log) - 1
      puts "Added entry [#{new_id}]." unless global[:quiet]
    end

    def self.run_remove(argv, global, log)
      options = {
        tags: nil,
        value: nil
      }
      id = nil

      parser = OptionParser.new do |opts|
        opts.banner = "Usage: usefuldb remove <id> [options]"
        opts.on("--tags TAGS", "Match entry tags when removing by value") { |value| options[:tags] = value }
        opts.on("--value VALUE", "Match entry value when removing by attributes") { |value| options[:value] = value }
        opts.on("-h", "--help", "Show this help") do
          puts opts
          exit 0
        end
      end

      option_argv, positional = partition_argv(argv, value_flags: ["--tags", "--value"])
      parser.parse!(option_argv)
      id = positional.first.to_i if positional.first&.match?(/\A\d+\z/)

      load_db!(log, global)

      if id.nil?
        raise OptionParser::ParseError, "Entry id is required" if options[:value].nil?

        normalized_tags = UsefulDB::Utils.normalize_tags(options[:tags] || [])
        id = UsefulDB::Utils.find_entry_id(tags: normalized_tags, value: options[:value])
        raise EntryNotFound, "No entry matched the given tags and value" if id.nil?
      end

      removed = UsefulDB::Utils.get_entry(id)
      UsefulDB.remove(id, log)
      UsefulDB.dbSave(log, load_options(global))

      puts "Removed entry [#{id}]: #{removed['value']}" unless global[:quiet]
    end

    def self.run_show(argv, global, log)
      json = false

      parser = OptionParser.new do |opts|
        opts.banner = "Usage: usefuldb show <id> [options]"
        opts.on("--json", "Print entry as JSON") { json = true }
        opts.on("-h", "--help", "Show this help") do
          puts opts
          exit 0
        end
      end

      option_argv, positional = partition_argv(argv)
      parser.parse!(option_argv)

      id = positional.first
      raise OptionParser::ParseError, "Entry id is required" if id.nil?

      load_db!(log, global)
      entry = UsefulDB::Utils.get_entry(id.to_i)

      if json
        puts UsefulDB::JSONEncoder.generate(entry)
      else
        print_entries([entry], format: :human, ids: true)
      end
    end

    def self.run_count(global, log)
      load_db!(log, global)
      puts UsefulDB::Utils.count(log)
    end

    def self.run_export(argv, global, log)
      options = {
        output: nil,
        format: nil
      }

      parser = OptionParser.new do |opts|
        opts.banner = "Usage: usefuldb export [options] [file]"
        opts.on("-o", "--output FILE", "Write export to FILE (- for stdout)") { |value| options[:output] = value }
        opts.on("--format FORMAT", ImportExport::FORMATS.map(&:to_s), "Export format (yaml or json)") do |value|
          options[:format] = value.to_sym
        end
        opts.on("-h", "--help", "Show this help") do
          puts opts
          exit 0
        end
      end

      option_argv, positional = partition_argv(argv, value_flags: ["-o", "--output", "--format"])
      parser.parse!(option_argv)

      output = options[:output] || positional.first
      raise OptionParser::ParseError, "Output file is required (use - for stdout)" if output.nil?

      format = options[:format]
      format ||= UsefulDB::ImportExport.detect_format(output) if output != "-"
      format ||= :yaml

      load_db!(log, global)
      content = UsefulDB::ImportExport.export_content(UsefulDB::Utils.export_data, format: format)
      UsefulDB::ImportExport.write_export(output, content)

      unless global[:quiet] || output == "-"
        puts "Exported #{UsefulDB::Utils.count(log)} entries to #{output}."
      end
    end

    def self.run_import(argv, global, log)
      options = {
        input: nil,
        format: nil,
        mode: :merge
      }

      parser = OptionParser.new do |opts|
        opts.banner = "Usage: usefuldb import [options] [file]"
        opts.on("-i", "--input FILE", "Read import from FILE (- for stdin)") { |value| options[:input] = value }
        opts.on("--format FORMAT", ImportExport::FORMATS.map(&:to_s), "Import format (yaml or json)") do |value|
          options[:format] = value.to_sym
        end
        opts.on("--merge", "Merge entries into the current database (default)") { options[:mode] = :merge }
        opts.on("--replace", "Replace the current database with the import") { options[:mode] = :replace }
        opts.on("-h", "--help", "Show this help") do
          puts opts
          exit 0
        end
      end

      option_argv, positional = partition_argv(argv, value_flags: ["-i", "--input", "--format"])
      parser.parse!(option_argv)

      input = options[:input] || positional.first
      raise OptionParser::ParseError, "Input file is required (use - for stdin)" if input.nil?

      prepare_db_for_import!(log, global, replace: options[:mode] == :replace)

      imported = UsefulDB::ImportExport.parse_file(input, format: options[:format])
      result = UsefulDB::ImportExport.import!(imported, mode: options[:mode], log: log)
      UsefulDB.dbSave(log, load_options(global))

      return if global[:quiet]

      if result[:mode] == :replace
        puts "Replaced database with #{result[:total]} entries."
      else
        puts "Imported #{result[:added]} entries (#{result[:skipped]} skipped as duplicates). Database now has #{result[:total]} entries."
      end
    end

    def self.prepare_db_for_import!(log, global, replace:)
      db_options = load_options(global)

      if global[:db]
        UsefulDB::Utils.ensure_db!(log, db_options)
      elsif replace && !File.exist?(UsefulDB::Utils.db_path(db_options))
        UsefulDB::Utils.ensure_db!(log, db_options)
      else
        UsefulDB.setup(log) unless global[:db]
        UsefulDB.dbLoad(log, db_options)
      end
    end

    def self.print_entries(entries, format:, ids: false)
      case format
      when :json
        puts UsefulDB::JSONEncoder.generate(entries)
      when :value_only
        entries.each { |entry| puts entry["value"] }
      else
        if entries.empty?
          puts "No matching entries."
          return
        end

        entries.each do |entry|
          prefix = ids ? "[#{entry['id']}] " : ""
          puts "#{prefix}#{entry['value']}"
          puts "     tags: #{entry['tag'].join(', ')}"
          puts "     #{entry['description']}" unless entry['description'].to_s.empty?
          puts
        end
      end
    end

    def self.print_help(command = nil)
      case command
      when "search"
        puts <<~HELP
          Usage: usefuldb search [options] [tags...]

          Options:
            --any          Match entries with any tag (OR)
            --json         Print results as JSON
            --value-only   Print only entry values
            --ids          Include entry ids in human output
            -h, --help     Show this help
        HELP
      when "list"
        puts <<~HELP
          Usage: usefuldb list [options]

          Options:
            --json         Print results as JSON
            --tags-only    Print unique tags
            -h, --help     Show this help
        HELP
      when "add"
        puts <<~HELP
          Usage: usefuldb add [options]

          Options:
            --tags TAGS         Comma-separated search tags
            --value VALUE       Stored command, URL, or text
            --description TEXT  Entry description
            -h, --help          Show this help
        HELP
      when "remove", "rm"
        puts <<~HELP
          Usage: usefuldb remove <id> [options]

          Options:
            --tags TAGS    Match entry tags when removing by value
            --value VALUE  Match entry value when removing by attributes
            -h, --help     Show this help
        HELP
      when "show"
        puts <<~HELP
          Usage: usefuldb show <id> [options]

          Options:
            --json         Print entry as JSON
            -h, --help     Show this help
        HELP
      when "export"
        puts <<~HELP
          Usage: usefuldb export [options] [file]

          Options:
            -o, --output FILE  Write export to FILE (- for stdout)
            --format FORMAT    Export format: yaml or json
            -h, --help         Show this help
        HELP
      when "import"
        puts <<~HELP
          Usage: usefuldb import [options] [file]

          Options:
            -i, --input FILE   Read import from FILE (- for stdin)
            --format FORMAT    Import format: yaml or json
            --merge            Merge entries into the current database (default)
            --replace          Replace the current database with the import
            -h, --help         Show this help
        HELP
      else
        puts <<~HELP
          Usage: usefuldb [global options] <command> [arguments]

          A simple command and URL database searchable by tag.

          Commands:
            search [tags...]   Find entries by tag
            list               List all entries
            add                Add an entry
            remove <id>        Remove an entry by id
            show <id>          Show a single entry
            count              Print entry count
            export [file]      Export the database to YAML or JSON
            import [file]      Import a database export
            help [command]     Show help

          Global options:
            --db PATH          Database file (default: ~/.usefuldb/db.yaml)
            -q, --quiet        Suppress non-essential output
            -v, --verbose      Enable debug logging
            --version          Print version
            -h, --help         Show this help

          Examples:
            usefuldb search git push
            usefuldb search git commit --value-only
            usefuldb add --tags git,commit --value "git commit -m 'msg'" --description "Commit changes"
            usefuldb list --json
            usefuldb show 42
            usefuldb remove 42
            usefuldb export backup.yaml
            usefuldb import backup.yaml --merge
            usefuldb export -o - --format json | jq '.db | length'
        HELP
      end
    end
  end
end
