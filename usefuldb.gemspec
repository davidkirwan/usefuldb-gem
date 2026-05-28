# frozen_string_literal: true

require_relative "lib/usefuldb/version"

Gem::Specification.new do |spec|
  spec.name          = "usefuldb"
  spec.version       = UsefulDB::Version.to_s
  spec.authors       = ["David Kirwan"]
  spec.email         = ["davidkirwanirl@gmail.com"]

  spec.summary       = "Simple database for storage of useful commands and URLs"
  spec.description   = "Accessible through a command-line script, UsefulDB lets you store and search useful commands and URLs by tag."
  spec.homepage      = "https://github.com/davidkirwan/usefuldb-gem"
  spec.license       = "GPL-2.0-only"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata = {
    "source_code_uri" => "https://github.com/davidkirwan/usefuldb-gem",
    "changelog_uri"   => "https://github.com/davidkirwan/usefuldb-gem/blob/master/CHANGELOG",
    "homepage_uri"    => "https://github.com/davidkirwan/usefuldb-gem",
    "rubygems_mfa_required" => "true"
  }

  spec.bindir        = "bin"
  spec.executables   = ["usefuldb"]
  spec.require_paths = ["lib"]

  spec.files = [
    *Dir.glob("lib/**/*.rb"),
    *Dir.glob("bin/*"),
    *Dir.glob("resources/*"),
    "Gemfile",
    "Rakefile",
    "Makefile",
    "README.md",
    "CHANGELOG",
    "COPYING",
    "usefuldb.gemspec"
  ].select { |path| File.file?(path) }

  spec.add_dependency "logger", ">= 1.6"
  spec.add_development_dependency "bundler", "~> 4.0"
  spec.add_development_dependency "rake", "~> 13.0"

  spec.post_install_message = <<~INSTALL
    usefuldb - simple database for storage of useful commands and URLs
  INSTALL
end
