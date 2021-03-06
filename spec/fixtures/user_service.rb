class ZONEMapper
  include XmlSchemaMapper
  schema 'spec/fixtures/UserService.xsd'
  type 'ZONE'
  elements.each do |e|
    attr_accessor e.reader
  end
end

class FilterMapper
  include XmlSchemaMapper
  schema 'spec/fixtures/UserService.xsd'
  type 'Filter'
  elements.each do |e|
    attr_accessor e.reader
  end
end

class OptionsMapper
  include XmlSchemaMapper
  schema 'spec/fixtures/UserService.xsd'
  type 'Options'
  elements.each do |e|
    attr_accessor e.reader
  end
end

class GetFirstNameMapper
  include XmlSchemaMapper
  schema 'spec/fixtures/UserService.xsd'
  type 'GetFirstName'
  elements.each do |e|
    attr_accessor e.reader
  end
end


module AnotherNamespace
  class ZONEMapper
    include XmlSchemaMapper
    schema 'spec/fixtures/UserService.xsd'
    type 'ZONE'
    elements.each do |e|
      attr_accessor e.reader
    end
  end

  class FilterMapper
    include XmlSchemaMapper
    schema 'spec/fixtures/UserService.xsd'
    type 'Filter'
    elements.each do |e|
      attr_accessor e.reader
    end
  end

  class OptionsMapper
    include XmlSchemaMapper
    schema 'spec/fixtures/UserService.xsd'
    type 'Options'
    elements.each do |e|
      attr_accessor e.reader
    end
  end

  class GetFirstNameMapper
    include XmlSchemaMapper
    schema 'spec/fixtures/UserService.xsd'
    type 'GetFirstName'
    elements.each do |e|
      attr_accessor e.reader
    end
  end
end



module ArrayNamespace
  class ZONEMapper
    include XmlSchemaMapper
    schema 'spec/fixtures/UserService.xsd'
    type 'ZONE'
    elements.each do |e|
      attr_accessor e.reader
    end
  end

  class FilterMapper
    include XmlSchemaMapper
    schema 'spec/fixtures/UserService.xsd'
    type 'Filter'
    elements.each do |e|
      attr_accessor e.reader
    end
  end

  class OptionsMapper
    include XmlSchemaMapper
    schema 'spec/fixtures/UserService.xsd'
    type 'Options'
    elements.each do |e|
      attr_accessor e.reader
    end
  end

  class GetFirstNameMapper
    include XmlSchemaMapper
    schema 'spec/fixtures/UserService.xsd'
    type 'GetFirstName'
    elements.each do |e|
      attr_accessor e.reader
    end
  end

  class ArrayOfGetFirstNameMapper
    include XmlSchemaMapper
    schema 'spec/fixtures/UserService.xsd'
    type 'ArrayOfGetFirstName'
    elements.each do |e|
      attr_accessor e.reader
    end
  end

  class ArrayOfStringsMapper
    include XmlSchemaMapper
    schema 'spec/fixtures/UserService.xsd'
    type 'ArrayOfStrings'
    elements.each do |e|
      attr_accessor e.reader
    end
  end
end