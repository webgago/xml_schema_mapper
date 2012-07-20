require "thor"
require "thor/group"

module XsdMappers
  class CLI < Thor

    desc 'mappers path/to/xsd path/to/generate/classes', 'generate classes for xsd types'
    method_option :module_name, default: ''
    def mappers(schema_path, destination = './')
      schema(schema_path).types.each do |name, type|
        Mappers.new([name, schema_path, destination]).invoke_all
      end
    end

    desc 'converters path/to/xsd path/to/generate/classes', 'generate converters for xsd types'
    method_option :module_name, default: ''
    def converters(schema_path, destination = './')
      schema(schema_path).types.each do |name, type|
        Converters.new([name, schema_path, destination], options.merge(attributes: type.elements.keys)).invoke_all
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
    argument :destination, default: './'
    class_option :module_name, default: ''
    class_option :override, default: false
    class_option :base_type, default: nil
    class_option :force, default: true

    def self.source_root
      File.dirname(__FILE__)
    end

    def create_lib_file
      template('templates/mapper_class.erb', "app/#{destination}/#{name.underscore}_mapper.rb")
    end

    def create_test_file
      test = options[:test_framework] == "test" ? :test : :spec
      with_padding do
        template 'templates/mapper_spec.erb', "spec/#{destination}/#{name.underscore}_mapper_#{test}.rb"
      end
    end

    protected
    def attributes
      options[:attributes]
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
  end

  class Converters < Mappers
    class_option :attributes, type: :array
    class_option :force, default: false

    def create_lib_file
      template('templates/converter_class.erb', "app/#{destination}/#{name.underscore}_converter.rb")
    end

    def create_test_file
      test = options[:test_framework] == "test" ? :test : :spec
      with_padding do
        template 'templates/converter_spec.erb', "spec/#{destination}/#{name.underscore}_converter_#{test}.rb"
      end
    end
  end
end