require "xml_schema_mapper/version"
require "xml"
require "nokogiri"
require "active_support/concern"
require "active_support/core_ext/class"

require "xml_schema_mapper/element"
require "xml_schema_mapper/parser"

module XmlSchemaMapper
  extend ActiveSupport::Concern

  included do
    class_attribute :_schema
    class_attribute :_type
    class_attribute :elements
    self.elements = []
  end

  module ClassMethods
    def schema(location)
      self._schema = LibXML::XML::Schema.new(location)
    end

    def type(name)
      raise(%Q{call "schema 'path/to/your/File.xsd'" before calling "type"}) unless _schema
      self._type = _schema.types[name]
      define_elements!
    end

    def define_elements!
      _type.elements.values.each do |element|
        e = XmlSchemaMapper::Element.new(element)
        elements << e
        attr_accessor e.method_name
      end
    end

    def parse(string_or_node)
      case string_or_node
      when String
        string = File.exist?(string_or_node) ? File.read(string_or_node) : string_or_node
        XmlSchemaMapper::Parser.new(self).parse(string)
      when Nokogiri::XML::Node
        XmlSchemaMapper::Parser.new(self).parse(string_or_node)
      else
        raise(ArgumentError, "param must be a String or Nokogiri::XML::Node")
      end
    end
  end

  def element_names
    elements.map(&:name)
  end

end
