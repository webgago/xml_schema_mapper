Int     = Integer
Double  = Float
Decimal = Integer

module XmlSchemaMapper
  class Element
    attr_reader :xsd

    delegate :name, :namespace, :type, to: :xsd

    def initialize(xsd_element, klass=nil)
      @xsd   = xsd_element
      @klass = klass
    end

    def klass
      @klass ||= begin
        name = (klass_name || base_klass_name)
        name ? (name+"Mapper").constantize : XmlSchemaMapper.default_class
      rescue NameError
        name.constantize
      rescue NameError => e
        raise e, "NotImplimented type #{name.inspect}"
      end
    end

    def simple?
      [
          LibXML::XML::Schema::Types::XML_SCHEMA_TYPE_SIMPLE,
          LibXML::XML::Schema::Types::XML_SCHEMA_TYPE_BASIC
      ].include? @xsd.type.kind
    end

    def content_from(object)
      data = object.send(reader)
      data.respond_to?(:to_xml) ? data.to_xml : data
    end

    def method_name
      name.underscore
    end

    def writer
      "#{method_name}="
    end

    def reader
      "#{method_name}"
    end

    def xpath(xml)
      if namespace
        xml.at_xpath("./foo:#{name}", { 'foo' => @xsd.namespace })
      else
        xml.at_xpath("./#{name}")
      end
    end

    def elements
      @xsd.elements.keys.map(&:to_sym)
    end

    private

    def klass_name
      @xsd.type.name.camelize
    rescue NameError
      nil
    end

    def base_klass_name
      @xsd.base.name.camelize
    rescue NameError
      nil
    end

  end
end