# frozen_string_literal: true

module UsefulDB
  module JSONEncoder
    module_function

    def generate(value)
      encode(value)
    end

    def encode(value)
      case value
      when Hash
        "{" + value.map { |key, item| "#{encode(key.to_s)}:#{encode(item)}" }.join(",") + "}"
      when Array
        "[" + value.map { |item| encode(item) }.join(",") + "]"
      when String
        '"' + escape(value) + '"'
      when Numeric, TrueClass, FalseClass
        value.to_s
      when NilClass
        "null"
      else
        encode(value.to_s)
      end
    end

    def escape(value)
      value.gsub("\\", "\\\\")
        .gsub('"', '\\"')
        .gsub("\b", "\\b")
        .gsub("\f", "\\f")
        .gsub("\n", "\\n")
        .gsub("\r", "\\r")
        .gsub("\t", "\\t")
    end
  end
end
