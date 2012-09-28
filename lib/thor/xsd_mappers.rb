require "thor"
require "thor/group"

module XsdMappers
  class CLI < Thor

    desc 'generate path/to/xsd', 'generate mappers for xsd types'
    method_option :module_name, default: ''
    method_option :converter_module_name, default: ''
    method_option :'skip-converters', type: :boolean

    def generate(schema_path)
      schema(schema_path).types.each do |name, _|
        Mappers.new([name, schema_path], options).invoke_all
        Converters.new([name, schema_path], options).invoke_all unless options[:'skip-converters']
      end
    end

    protected

    def schema(path)
      @schema ||= LibXML::XML::Schema.cached(path)
    end

  end

  class Mappers < Thor::Group
    include Thor::Actions

    # Define arguments and options
    argument :name
    argument :schema_path
    class_option :module_name, default: ''
    class_option :override, default: false
    class_option :base_type, default: nil
    class_option :force, default: true

    def self.source_root
      File.dirname(__FILE__)
    end

    def module_path
      options[:module_name] ? options[:module_name].underscore : ""
    end

    def create_lib_file
      filename = "#{name.underscore}_mapper.rb"
      template('templates/mapper_class.erb', File.join('app/mappers/', module_path, filename))
    end

    def create_test_file
      test     = options[:test_framework] == "test" ? :test : :spec
      filename = "#{name.underscore}_mapper_#{test}.rb"
      with_padding do
        template 'templates/mapper_spec.erb', File.join("#{test}/mappers/", module_path, filename)
      end
    end

    protected

    def subclasses
      type.annonymus_subtypes_recursively.inject({ }, &:merge)
    end

    def schema
      @schema ||= LibXML::XML::Schema.cached(schema_path)
    end

    def elements
      @elements ||= type.elements.values
    end

    def type
      @type ||= schema.types[name]
    end

    def element_annotation(element)
      type    = element.type.name || "#{element.name}"
      comment = element.annotation || element.type.annotation

      if is_a_simple?(element.type)
        "#{comment}\n" <<
            "@return [#{type.camelize}]"
      else
        "#{comment}\n" <<
            "@return [#{module_name}#{type.camelize}Mapper]"
      end
    end

    def is_a_simple?(type)
      [LibXML::XML::Schema::Types::XML_SCHEMA_TYPE_SIMPLE,
       LibXML::XML::Schema::Types::XML_SCHEMA_TYPE_BASIC].include?(type.kind)
    end

    def module_name
      if options[:module_name].presence
        "#{options[:module_name]}::"
      else
        ""
      end
    end

    def mapper_name
      class_name = "#{name.underscore.camelize}Mapper"
      "#{module_name}#{class_name}"
    end
  end

  class Converters < Mappers
    class_option :attributes, type: :array
    class_option :converter_module_name, default: ""
    class_option :force, default: false
    class_option :skip, default: true

    def module_path
      options[:converter_module_name] ? options[:converter_module_name].underscore : ""
    end

    def create_lib_file
      filename = "#{name.underscore}_converter.rb"
      template('templates/converter_class.erb', File.join('app/converters/', module_path, filename))
    end

    def create_test_file
      test     = options[:test_framework] == "test" ? :test : :spec
      filename = "#{name.underscore}_converter_#{test}.rb"
      with_padding do
        template 'templates/converter_spec.erb', File.join("#{test}/converters/", module_path, filename)
      end
    end

    def converter_name
      "#{name.underscore.camelize}Converter"
    end
  end
end
