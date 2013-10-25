require 'rubygems'
require 'rake'



Gem::Specification.new do |s|
  s.name        = 'usefuldb'
  s.version     = '0.1.0'
  s.date        = '2013-10-25'
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
usefuldb - simple database for storage of useful commands and or urls.

usefuldb is released under the creative commons attribution-sharealike 3.0 unported (cc by-sa 3.0) licence.
for more information see: http://creativecommons.org/licenses/by-sa/3.0/
INSTALL

  s.license 	= 'CC BY-SA 3.0'
  s.add_development_dependency "bundler"
  s.add_development_dependency "test-unit"
end
