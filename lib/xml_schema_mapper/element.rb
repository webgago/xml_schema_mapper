module XmlSchemaMapper
  class Element
    attr_reader :xsd

    def initialize(xsd_element, klass=nil)
      @xsd   = xsd_element
      @klass = klass
    end

    def klass
      @klass ||= begin
        klass_name = @xsd.type.name.underscore.classify
        klass_name.safe_constantize || struct_for(klass_name)
      rescue
        nil
      end
    end

    def simple?
      [
          LibXML::XML::Schema::Types::XML_SCHEMA_TYPE_SIMPLE,
          LibXML::XML::Schema::Types::XML_SCHEMA_TYPE_BASIC
      ].include? @xsd.type.kind
    end

    def name
      @xsd.name
    end

    def method_name
      name.underscore
    end

    def writer
      "#{method_name}="
    end

    def xpath(xml)
      if @xsd.namespace
        xml.at_xpath("./foo:#{name}", { 'foo' => @xsd.namespace })
      else
        xml.at_xpath("./#{name}")
      end
    end

    def elements
      @xsd.elements.keys.map(&:to_sym)
    end

    def struct_for(klass_name)
      Struct.new(klass_name, *elements)
    end
  end
end