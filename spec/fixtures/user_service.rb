class ZONEMapper
  include XmlSchemaMapper
  schema 'spec/fixtures/UserService.xsd'
  type 'ZONE'
end

class FilterMapper
  include XmlSchemaMapper
  schema 'spec/fixtures/UserService.xsd'
  type 'Filter'
end

class OptionsMapper
  include XmlSchemaMapper
  schema 'spec/fixtures/UserService.xsd'
  type 'Options'
end

class GetFirstNameMapper
  include XmlSchemaMapper
  schema 'spec/fixtures/UserService.xsd'
  type 'GetFirstName'
end
