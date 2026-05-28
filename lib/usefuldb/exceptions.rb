# frozen_string_literal: true

module UsefulDB
  class EntryInDB < StandardError; end
  class EmptyDB < StandardError; end
  class KeyOutOfBounds < StandardError; end
  class EntryNotFound < StandardError; end
  class ImportError < StandardError; end
end
