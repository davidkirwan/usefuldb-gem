require 'rubygems'
require 'usefuldb'

module UsefulDB

  class Version
    class << self
      
      MAJOR = 0 unless defined? MAJOR
      MINOR = 0 unless defined? MINOR
      PATCH = 12 unless defined? PATCH

      def to_s
        [MAJOR, MINOR, PATCH].compact.join('.')
      end

    end
  end

end
