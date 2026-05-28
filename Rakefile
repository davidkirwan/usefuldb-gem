# frozen_string_literal: true

require_relative "lib/usefuldb/version"
require "bundler/gem_tasks"

desc "List available Rake tasks"
task :menu do
  puts <<~MSG
    rake build    # Build usefuldb-#{UsefulDB::Version}-*.gem into pkg/
    rake install  # Build and install the gem locally
    rake release  # Tag, build, and push to RubyGems (maintainers only)
    rake clean    # Remove built artifacts from pkg/
  MSG
end

task default: :menu
