require 'rubygems'
require 'rake'



Gem::Specification.new do |s|
  s.name        = 'usefuldb'
  s.version     = '0.2.0'
  s.date        = '2015-10-02'
  s.summary     = "usefuldb - simple database for storage of useful commands and or urls."
  s.description = "Accessible through a commandline script, UsefulDB allows the user to store information about a useful command or useful url"
  s.authors     = ["David Kirwan"]
  s.email       = ['davidkirwanirl@gmail.com']
  s.require_paths = ["lib"]
  s.files       = FileList['lib/**/*.rb',
                      'bin/*',
                      '[A-Z]*',
                      'resources/*',
                      'test/**/*'].to_a
  s.homepage    = 'http://rubygems.org/gems/usefuldb'
  s.required_ruby_version = '>= 1.8.7'
  s.executables << 'usefuldb'

  s.post_install_message = <<-INSTALL
usefuldb - simple database for storage of useful commands and or urls
INSTALL

  s.license 	= 'GPL 2.0'
  s.add_development_dependency "bundler"
  s.add_development_dependency "test-unit"
end
