module XmlSchemaMapper
  class TestBuilder
    module Helper
      def build_mapper(klass)
        XmlSchemaMapper::TestBuilder.new(klass).build
      end

      def build_described_mapper
        build_mapper described_class
      end
    end

    def initialize(klass)
      @klass  = klass
      @module = resolve_module
    end

    def build
      instance = @klass.new
      @klass.elements.each do |e|
        if e.array?
          fill_array_element(e, instance)
        else
          fill_element(e, instance)
        end
      end
      instance
    end

    def fill_element(element, instance)
      if element.simple?
        instance.send(element.writer, content_for(element)) if instance.respond_to?(element.writer)
      else
        instance.send(element.writer, resolve_element_builder(element).build) if instance.respond_to?(element.writer)
      end
    end

    def fill_array_element(element, instance)
      instance.send(element.writer, [])
      if element.simple?
        3.times do
          instance.send(element.reader) << content_for(element) if instance.respond_to?(element.writer)
        end
      else
        3.times do
          instance.send(element.reader) << resolve_element_builder(element).build if instance.respond_to?(element.writer)
        end
      end
    end

    def content_for(element)
      case element.type.kind
      when LibXML::XML::Schema::Types::XML_SCHEMA_TYPE_SIMPLE
        element.type.base.name
      when LibXML::XML::Schema::Types::XML_SCHEMA_TYPE_BASIC
        element.type.name
      else
        "content"
      end
    end

    private

    def resolve_element_builder(element)
      TestBuilder.new(parsers_for_resolve(element).find(&:safe_constantize).safe_constantize) or raise_class_not_found(e)
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
