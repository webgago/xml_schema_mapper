require "thor"
require "thor/group"

module XsdMappers
  class CLI < Thor

    desc 'generate path/to/xsd', 'generate mappers for xsd types'
    method_option :module_name, default: ''
    method_option :'skip-converters', type: :boolean

    def generate(schema_path)
      schema(schema_path).types.each do |name, _|
        Mappers.new([name, schema_path]).invoke_all
        Converters.new([name, schema_path]).invoke_all unless options[:'skip-converters']
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

    def create_lib_file
      template('templates/mapper_class.erb', "app/mappers/#{name.underscore}_mapper.rb")
    end

    def create_test_file
      test = options[:test_framework] == "test" ? :test : :spec
      with_padding do
        template 'templates/mapper_spec.erb', "spec/mappers/#{name.underscore}_mapper_#{test}.rb"
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
      type    = element.type.name || "annonymus subclass: #{element.name}"
      comment = (element.annotation || element.type.annotation).to_s.gsub("\n", "\n# ")
      "# @attr [#{type}] #{comment}"
    end

    def mapper_name
      class_name = "#{name.camelize}Mapper"
      options[:module_name].present? ? "#{options[:module_name]}::#{class_name}" : class_name
    end
  end

  class Converters < Mappers
    class_option :attributes, type: :array
    class_option :force, default: false
    class_option :skip, default: true

    def create_lib_file
      template('templates/converter_class.erb', "app/converters/#{name.underscore}_converter.rb")
    end

    def create_test_file
      test = options[:test_framework] == "test" ? :test : :spec
      with_padding do
        template 'templates/converter_spec.erb', "spec/converters/#{name.underscore}_converter_#{test}.rb"
      end
    end
  end
end