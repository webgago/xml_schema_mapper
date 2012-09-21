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
        if e.array?
          write_array_element(e, instance, xml)
        else
          write_element(e, instance, xml)
        end
      end
      instance
    end

    def write_element(element, instance, xml)
      node = get_node_by_xpath(element, xml)
      if element.simple?
        instance.send(element.writer, content_for(node)) if instance.respond_to?(element.writer)
      else
        instance.send(element.writer, resolve_element_parser(element).parse(node)) if instance.respond_to?(element.writer)
      end
    end

    def write_array_element(element, instance, xml)
      instance.send(element.writer, [])
      if element.simple?
        get_nodes_by_xpath(element, xml).each do |node|
          instance.send(element.reader) << content_for(node) if instance.respond_to?(element.writer)
        end
      else
        get_nodes_by_xpath(element, xml).each do |node|
          instance.send(element.reader) << resolve_element_parser(element).parse(node) if instance.respond_to?(element.writer)
        end
      end
    end

    def content_for(node)
      node.content if node
    end

    def get_node_by_xpath(element, xml)
      if element.namespace
        xml.at_xpath("./foo:#{element.name}", { 'foo' => element.namespace })
      else
        xml.at_xpath("./#{element.name}")
      end
    end

    def get_nodes_by_xpath(element, xml)
      if element.namespace
        xml.xpath("./foo:#{element.name}", { 'foo' => element.namespace })
      else
        xml.xpath("./#{element.name}")
      end
    end

    def document(xml)
      return xml if xml.is_a?(Nokogiri::XML::Node)
      Nokogiri::XML(xml).root
    end

    private

    def resolve_element_parser(element)
      parsers_for_resolve(element).find(&:safe_constantize).safe_constantize or raise_class_not_found(e)
    end

    def parsers_for_resolve(element)
      %W(#{element.mapper_class_name} #{element.klass_name} #{@klass.name}::#{element.klass_name})
    end

    def raise_class_not_found(element)
      raise NameError, "No one of the classes #{parsers_for_resolve(element)} cannot be found"
    end

    def resolve_module
      if @klass.name.index('::')
        @klass.name[0..@klass.name.index('::')-1].safe_constantize
      else
        Object
      end
    end
  end
end
