Int     = Integer
Double  = Float
Decimal = Integer

module XmlSchemaMapper
  class Element
    attr_reader :xsd

    delegate :name, :namespace, :type, :base, to: :xsd

    def initialize(xsd_element)
      @xsd = xsd_element
    end

    def simple?
      [
          LibXML::XML::Schema::Types::XML_SCHEMA_TYPE_SIMPLE,
          LibXML::XML::Schema::Types::XML_SCHEMA_TYPE_BASIC
      ].include? type.kind
    end

    def content_from(object)
      data = object.send(reader)
      data.respond_to?(:to_xml) ? data.to_xml : data
    end

    def method_name
      name.underscore.to_sym
    end

    def writer
      :"#{method_name}="
    end

    def reader
      method_name
    end

    def xpath(xml)
      if namespace
        xml.at_xpath("./foo:#{name}", { 'foo' => @xsd.namespace })
      else
        xml.at_xpath("./#{name}")
      end
    end

    def converter_class
      (klass_name + "Converter").constantize
    end

    def mapper_class
      mapper_class_name.constantize
    end

    def mapper_class_name
      klass_name + "Mapper"
    end

    def klass_name
      type.name.camelize
    rescue NoMethodError
      nil
    end

    def base_klass_name
      base.name.camelize
    rescue NoMethodError
      nil
    end

  end
end