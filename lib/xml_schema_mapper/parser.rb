module XmlSchemaMapper
  class Parser
    attr_reader :xml

    def initialize(klass)
      @klass = klass
    end

    def parse(xml)
      instance = @klass.new
      xml = document(xml)
      @klass.elements.each do |e|
        if e.simple?
          instance.send(e.writer, e.xpath(xml).inner_text)
        else
          instance.send(e.writer, e.klass.parse(e.xpath(xml)))
        end
      end
      instance
    end

    def document(xml)
      return xml if xml.is_a?(Nokogiri::XML::Node)
      Nokogiri::XML(xml).root
    end
  end
end