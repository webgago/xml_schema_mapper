module XmlSchemaMapper
  class Parser
    def initialize(klass)
      @klass  = klass
      @module = resolve_module
    end

    def parse(xml)
      instance = @klass.new
      xml      = document(xml)
      @klass.elements.each do |e|
        if e.simple?
          instance.send(e.writer, content_for(e, xml)) if instance.respond_to?(e.writer)
        else
          instance.send(e.writer, element_parser(e).parse(get_by_xpath(e, xml))) if instance.respond_to?(e.writer)
        end
      end
      instance
    end

    def element_parser(e)
      find_class(e)
    end

    def find_class(e)
      "#{@module.name}::#{e.mapper_class_name}".safe_constantize ||
          "#{@klass.name}::#{e.klass_name}".safe_constantize ||
          "#{e.klass_name}".constantize
    end

    def content_for(element, xml)
      node = get_by_xpath(element, xml)
      node.content if node
    end

    def get_by_xpath(element, xml)
      if element.namespace
        xml.at_xpath("./foo:#{element.name}", { 'foo' => element.namespace })
      else
        xml.at_xpath("./#{element.name}")
      end
    end

    def document(xml)
      return xml if xml.is_a?(Nokogiri::XML::Node)
      Nokogiri::XML(xml).root
    end

    private
    def resolve_module
      if @klass.name.index('::')
        @klass.name[0..@klass.name.index('::')-1].safe_constantize
      else
        Object
      end
    end
  end
end