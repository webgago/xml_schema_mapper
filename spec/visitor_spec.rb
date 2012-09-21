require "spec_helper"
require "stringio"

describe "Generate XML by Visitor Pattern" do

  class MarshalVisitor

    attr_reader :namespace_mapper

    def initialize(data, namespace_mapper)
      @data             = data
      @namespace_mapper = namespace_mapper
      @tab              = 0
      @buf              = ""
      @io               = StringIO.new @buf
    end

    def visit_array(element, data, *args)
      data.each { |d| element.accept(self, d) }
    end

    def visit(element, data, *args)
      @io.print tag_open(element, data)

      with_padding(element) do
        element.elements.each do |e|
          e.accept(self, data.elements[e.reader])
        end
      end

      @io.print tag_close(element)
    end

    def to_xml
      @data.class.elements.each do |e|
        e.accept(self, @data.elements[e.reader])
      end
      @buf
    end

    private

    def tag_name(element)
      prefix = namespace_mapper.prefix(element.namespace)
      if prefix.present?
        "#{prefix}:#{element.name}"
      else
        element.name
      end
    end

    def tag_open(element, data)
      if element.type.attributes.empty?
        attrs = ""
      else
        attrs = " " << data.attrs.map { |name, val| %Q{#{name}="#{val}"} }.join(' ')
      end

      if element.simple?
        padding << "<#{tag_name(element)}#{attrs}>" << "#{data}"
      else
        padding << "<#{tag_name(element)}#{attrs}>\n"
      end
    end

    def tag_close(element)
      if element.simple?
        "</#{tag_name(element)}>\n"
      else
        padding << "</#{tag_name(element)}>\n"
      end
    end

    def padding
      ("  " * @tab)
    end

    def with_padding(element)
      inc_tab! if element.elements.present?
      yield
      dec_tab! if element.elements.present?
    end

    def inc_tab!
      @tab = @tab + 1
    end

    def dec_tab!
      @tab = @tab - 1
    end
  end

  class NamespacePrefixMapper
    class_attribute :map
    self.map = { }

    map["ds"]    = "http://www.w3.org/2000/09/xmldsig#"
    map["xsi"]   = "http://www.w3.org/2001/XMLSchema-instance"
    map["xml"]   = "http://www.w3.org/XML/1998/namespace"
    map["xs"]    = "http://www.w3.org/2001/XMLSchema"
    map["xop"]   = "http://www.w3.org/2004/08/xop/include"
    map["xmime"] = "http://www.w3.org/2005/05/xmlmime"

    def self.add(hash = { })
      map.merge! hash.stringify_keys
    end

    def self.prefix(uri)
      map.invert[uri] or ''
    end

    def self.uri(prefix)
      map[prefix]
    end
  end

  let(:options) { o = OptionsMapper.new; o.one = 'one'; o.two = 'two'; o }
  let(:object) do
    f       = FilterMapper.new; f.age = 50; f.gender = 'male'
    g       = GetFirstNameMapper.new; g.user_identifier = '001'; g.is_out = 'a'; g.zone = 'b'; g.filter = f; g.options = options
    g.attrs = { 'id' => '1000', 'default' => '1' }
    g
  end

  it "" do
    mapper       = ArrayNamespace::ArrayOfGetFirstNameMapper.new
    mapper.query = [object, object.dup]

    class UserNamespaceMapper < NamespacePrefixMapper

    end

    UserNamespaceMapper.add type: "http://example.com/UserService/type/",
                            com:  "http://example.com/common/"

    visitor = MarshalVisitor.new(mapper, UserNamespaceMapper)
    visitor.to_xml.should eql <<-X
<type:query id="1000" default="1">
  <type:userIdentifier>001</type:userIdentifier>
  <type:filter>
    <type:age>50</type:age>
    <type:gender>male</type:gender>
  </type:filter>
  <type:isOut>a</type:isOut>
  <com:zone>b</com:zone>
  <type:options>
    <com:one>one</com:one>
    <com:two>two</com:two>
  </type:options>
</type:query>
<type:query id="1000" default="1">
  <type:userIdentifier>001</type:userIdentifier>
  <type:filter>
    <type:age>50</type:age>
    <type:gender>male</type:gender>
  </type:filter>
  <type:isOut>a</type:isOut>
  <com:zone>b</com:zone>
  <type:options>
    <com:one>one</com:one>
    <com:two>two</com:two>
  </type:options>
</type:query>
    X
  end

end