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
require "xml_schema_mapper/namespace_resolver"

module XmlSchemaMapper
  extend ActiveSupport::Concern
  mattr_accessor :namespace_resolver_class

  included do
    class_attribute :_schema
    class_attribute :_type
    class_attribute :namespace_resolver_class
    include Virtus
  end

  module ClassMethods
    def schema(location=nil)
      if location
        self._schema = LibXML::XML::Schema.cached(location)
      else
        self._schema
      end
    end

    def type(name=nil)
      raise(%Q{call "schema 'path/to/your/File.xsd'" before calling "type"}) unless _schema
      if name
        self._type = _schema.types[name]
        attr_accessor :attrs
      else
        self._type
      end
    end

    def annonymus_type(name)
      raise(%Q{call "schema 'path/to/your/File.xsd'" before calling "type"}) unless _schema
      path = name.split('::')
      type = _schema.types[path.shift]
      self._type = path.map do |n|
        type = type.elements[n].type if type
      end.last
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

    def elements
      @elements ||= type.elements.values.map do |element|
        XmlSchemaMapper::Element.new(element)
      end
    end

    def attrs
      @attrs ||= type.attributes
    end

    def build_tree
      instance = new
      self.elements.each do |e|
        instance[e.reader] = e.mapper_class.build_tree if e.complex?
      end
      instance
    end
  end

  delegate :first, :last, :each, :length, :size, :all?, :any?, :one?, :empty?, to: :element_values

  def [](key)
    send(key)
  end

  def []=(key, val)
    send(:"#{key}=", val)
  end

  def accept(visitor, *args)
    visitor.visit(self, *args)
  end

  def simple?
    _type.simple?
  end

  def values
    _type.facets.map &:value
  end

  def type
    self.class.type
  end

  def schema
    self.class.schema
  end

  def element_names
    elements.keys
  end

  def element_values
    elements.values
  end

  def elements
    type.elements.values.inject({}) do |hash, element|
      hash.merge element.name.underscore.to_sym => send(element.name.underscore.to_sym)
    end
  end

  def to_xml(options = {})
    xml_document.root.to_xml({:encoding => 'UTF-8'}.merge(options))
  end

  def xml_document
    document = XmlSchemaMapper::Builder.create_document(_type)
    document.root.namespace = root_namespace

    builder = XmlSchemaMapper::Builder.new(self, document.root, namespace_resolver)
    builder.build
    builder.document
  end

  def root_namespace
    namespaces = namespace_resolver || schema.namespaces
    ns = namespaces.find_by_href (global_element || _type).namespace
    document.root.add_namespace_definition(ns.prefix, ns.href)
  end

  def namespace_resolver
    case
      when self.class.namespace_resolver_class
        self.class.namespace_resolver_class.new(schema.namespaces)
      when XmlSchemaMapper.namespace_resolver_class
        XmlSchemaMapper.namespace_resolver_class.new(schema.namespaces)
    end
  end

  def global_element
    schema.elements.values.find { |e| e.type.name == _type.name }
  end

end
