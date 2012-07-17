module XmlSchemaMapper
  class Builder
    attr_reader :source, :namespaces

    def initialize(source)
      @source     = source
      @klass      = source.class
      @namespaces = @klass._schema.namespaces.inject({ }) { |hash, ns| hash.merge ns.prefix => ns.href }
    end

    def build
      elements.each do |element|
        node = create_element(element)
        add_node node, element.xsd.namespace
      end
      document.root
    end

    def elements
      @klass.elements
    end

    def add_node(node, namespace)
      document.root << node
      if namespace
        node.namespace = find_namespace_definition(namespace)
      end
    end

    def find_namespace_definition(namespace)
      document.root.namespace_scopes.find { |n| n.href == namespace }
    end

    def create_element(element)
      if element.simple?
        create_simple(element)
      else
        create_complex(element)
      end
    end

    def create_simple(element)
      document.create_element(element.name, value(element))
    end

    def create_complex(element)
      child = source.send(element.reader)
      if child.is_a?(XmlSchemaMapper)
        child.xml_document.root
      else
        child.to_xml
      end
    end

    def value(element)
      data = source.send(element.reader)
      data.respond_to?(:to_xml) ? data.to_xml : data
    end

    def document
      @document ||= begin
        d      = Nokogiri::XML::Document.new
        d.root = d.create_element(@klass._type.name.camelize(:lower))
        @namespaces.each do |prefix, href|
          d.root.add_namespace(prefix, href)
        end
        d
      end
    end
  end
end