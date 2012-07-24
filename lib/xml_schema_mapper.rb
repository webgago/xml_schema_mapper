require "xml_schema_mapper/version"
require "xml"
require "nokogiri"
require "active_support/concern"
require "active_support/core_ext/class"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/string/inflections"
require "virtus"

require "xml_schema_mapper/element"
require "xml_schema_mapper/parser"
require "xml_schema_mapper/builder"

module XmlSchemaMapper
  extend ActiveSupport::Concern

  included do
    class_attribute :_schema
    class_attribute :_type
    class_attribute :elements
    self.elements = []
    include Virtus
  end

  module ClassMethods
    def schema(location)
      self._schema = LibXML::XML::Schema.cached(location)
    end

    def type(name)
      raise(%Q{call "schema 'path/to/your/File.xsd'" before calling "type"}) unless _schema
      self._type = _schema.types[name]
      define_elements!
    end

    def annonymus_type(name)
      raise(%Q{call "schema 'path/to/your/File.xsd'" before calling "type"}) unless _schema
      path = name.split('::')
      type = _schema.types[path.shift]
      self._type = path.map do |n|
        type = type.elements[n].type
      end.last
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
      return if string_or_node.nil?
      case string_or_node
      when String
        string = File.exist?(string_or_node) ? File.read(string_or_node) : string_or_node
        XmlSchemaMapper::Parser.new(self).parse(string)
      when Nokogiri::XML::Node
        XmlSchemaMapper::Parser.new(self).parse(string_or_node)
      else
        raise(ArgumentError, "param must be a String or Nokogiri::XML::Node, but \"#{string_or_node.inspect}\" given")
      end
    end
  end

  def element_names
    elements.map(&:name)
  end

  def to_xml(options = { })
    xml_document.root.to_xml({ :encoding => 'UTF-8' }.merge(options))
  end

  def xml_document
    document = XmlSchemaMapper::Builder.create_document(_type)
    builder  = XmlSchemaMapper::Builder.new(self, document.root)
    builder.build
    builder.document
  end

end
