module XmlSchemaMapper
  class Parser
    def initialize(klass)
      @klass  = klass
      @module = @klass.name.deconstantize.safe_constantize
    end

    def parse(xml)
      instance = @klass.new
      xml      = document(xml)
      @klass.elements.each do |e|
        if e.simple?
          instance.send(e.writer, content_for(e, xml))
        else
          instance.send(e.writer, element_parser(e).parse(e.xpath(xml)))
        end
      end
      instance
    end

    def element_parser(e)
      find_class(e)
    end

    def find_class(e)
      "#{@module.name}::#{e.mapper_class_name}".constantize
    end

    def content_for(element, xml)
      node = element.xpath(xml)
      node.content if node
    end

    def document(xml)
      return xml if xml.is_a?(Nokogiri::XML::Node)
      Nokogiri::XML(xml).root
    end
  end
end