class NoToXmlError < NoMethodError
end

module XmlSchemaMapper
  class Builder

    attr_reader :document, :parent

    delegate :elements, :to => :@klass

    def initialize(source, parent)
      @parent   = parent.is_a?(Nokogiri::XML::Document) ? parent.root : parent
      @document = parent.document
      @source   = source
      @klass    = source.class
      @schema   = @klass._schema
    end

    def build
      elements.each do |element|
        add_element_namespace_to_root!(element)
        node = create_node(element)
        parent << node unless node.content.blank?
      end
      self
    end

    private

    attr_reader :source, :schema

    def create_node(element)
      setup_namespace(element) do
        element.simple? ? simple_node(element) : complex_node(element)
      end
    end

    def setup_namespace(element)
      yield.tap do |node|
        return if node.nil?
        node.namespace = find_namespace_definition(element.namespace)
      end
    end

    def simple_node(element)
      document.create_element(element.name, element.content_from(source))
    end

    def complex_node(element)
      object            = source.send(element.reader)
      complex_root_node = document.create_element(element.name)

      if object.is_a?(XmlSchemaMapper)
        complex_node_from_mapper(complex_root_node, object)
      else
        complex_node_from_xml(complex_root_node, object)
      end
    rescue NoToXmlError
      raise("object of #{source.class}##{element.reader} should respond to :to_xml")
    end

    def complex_node_from_xml(root, object)
      return root if object.nil?
      if object.respond_to?(:to_xml)
        root << object.to_xml
      else
        raise NoToXmlError
      end
    end

    def complex_node_from_mapper(root, object)
      XmlSchemaMapper::Builder.build(object, root).parent
    end

    def add_element_namespace_to_root!(element)
      if element.namespace
        ns = schema.namespaces.find_by_href(element.namespace)
        raise "prefix for namespace #{element.namespace.inspect} not found" unless ns

        document.root.add_namespace(ns.prefix, ns.href)
      end
    end

    def find_namespace_definition(href)
      document.root.namespace_definitions.find { |ns| ns.href == href }
    end

    # CLASS_METHODS

    def self.create_document(xtype)
      Nokogiri::XML::Document.new.tap do |doc|
        doc.root = doc.create_element(xtype.name.camelize(:lower))
      end
    end

    def self.build(mapper, parent)
      XmlSchemaMapper::Builder.new(mapper, parent).build
    end

  end
end