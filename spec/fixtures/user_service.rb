class Filter
  include XmlSchemaMapper
  schema 'spec/fixtures/UserService.xsd'
  type 'Filter'
end

class Options
  include XmlSchemaMapper
  schema 'spec/fixtures/UserService.xsd'
  type 'Options'
end

class GetFirstName
  include XmlSchemaMapper
  schema 'spec/fixtures/UserService.xsd'
  type 'GetFirstName'
end

