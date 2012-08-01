require "spec_helper"

describe XmlSchemaMapper::Builder do
  let(:options) { o = OptionsMapper.new; o.one = 'one'; o.two = 'two'; o }
  let(:object) do
    f = FilterMapper.new; f.age = 50; f.gender = 'male'
    g = GetFirstNameMapper.new; g.user_identifier = '001'; g.is_out = 'a'; g.zone = 'b'; g.filter = f; g.options = options
    g
  end

  let(:document) { XmlSchemaMapper::Builder.create_document(object._type) }
  subject { XmlSchemaMapper::Builder.new(object, document.root) }

  context 'after initialize' do
    its(:source) { should be object }
  end

  context 'on build' do
    let(:element) { stub(namespace: 'http://example.com/common/', name: 'element', simple?: true, content_from: 1) }
    let(:complex_element) { stub(namespace: 'http://example.com/common/', name: 'element', simple?: false) }
    let(:stub_node) { document.create_element('element') }

    before do
      subject.stub(elements: [element], value: 1)
    end

    it "should create node for each element" do
      subject.should_receive(:create_node).with(element).and_return(stub_node)
      subject.build
    end

    it "should create simple_node if element#simple?" do
      element.should_receive(:simple?).and_return(true)
      subject.should_receive(:simple_node).and_return(stub_node)
      subject.build
    end

    it "should create complex_node unless element#simple?" do
      element.should_receive(:simple?).and_return(false)
      subject.should_receive(:complex_node).and_return(stub_node)
      subject.build
    end

    it "should add namespace to root node" do
      namespace = stub(prefix: 'w', href: 'namespace')
      element.stub(reader: 'is_out', namespace: 'namespace')
      subject.stub_chain('schema.namespaces.find_by_href').and_return(namespace)

      subject.build

      subject.document.root.namespaces.should include "xmlns:w" => "namespace"
    end

    it "should raise error when element namespace not found" do
      element.stub(namespace: 'namespace')
      subject.stub_chain('schema.namespaces.find_by_href').and_return(nil)

      expect { subject.build }.to raise_error("prefix for namespace \"namespace\" not found")
    end

    it "should set namespace for node" do
      subject.stub(simple_node: stub_node)
      subject.build
      stub_node.namespace.prefix.should eql 'cm'
      stub_node.namespace.href.should eql 'http://example.com/common/'
    end

    it "should create complex element with namespace" do
      complex_element.stub(reader: 'filter')
      element_node = document.create_element('element')
      age_node = document.create_element('age', '50')
      gender_node = document.create_element('gender', 'male')
      subject.stub(elements: [complex_element])

      subject.document.should_receive(:create_element).with('element').and_return(element_node)
      subject.document.should_receive(:create_element).with('age', 50).and_return(age_node)
      subject.document.should_receive(:create_element).with('gender', 'male').and_return(gender_node)

      subject.build

      element_node.namespace.prefix.should eql 'cm'
      gender_node.namespace.prefix.should eql 'tns'
      age_node.namespace.prefix.should eql 'tns'
    end

    it "should create complex element without namespace" do
      complex_element.stub(namespace: nil, reader: 'options')
      subject.stub(elements: [complex_element])

      element_node = document.create_element('element')
      one_node = document.create_element('one', 'one')
      two_node = document.create_element('two', 'two')

      subject.document.should_receive(:create_element).with('element').and_return(element_node)
      subject.document.should_receive(:create_element).with('one', 'one').and_return(one_node)
      subject.document.should_receive(:create_element).with('two', 'two').and_return(two_node)

      subject.build

      element_node.namespace.should be_nil
      one_node.namespace.should be_nil
      two_node.namespace.should be_nil
    end

    it "should accept not a XmlSchemaMapper for node" do
      object.stub(not_a_mapper: document.create_element('not_a_mapper'))
      complex_element.stub(namespace: 'http://example.com/common/', reader: 'not_a_mapper')
      subject.stub(elements: [complex_element])
      element_node = document.create_element('element') << object.not_a_mapper.to_xml

      element_node.should_receive(:<<).with(object.not_a_mapper.to_xml).and_return(element_node)
      subject.document.should_receive(:create_element).with('element').and_return(element_node)

      subject.build
    end

    it "if array build element for each" do
      object.stub(array_mappers: [object.filter,object.filter])
      complex_element.stub(namespace: 'http://example.com/common/', reader: 'array_mappers')
      subject.stub(elements: [complex_element])

      subject.parent.should_receive(:<<).with(instance_of(Nokogiri::XML::NodeSet))
      subject.build
    end

    it "if array build element for each" do
      mapper = ArrayNamespace::ArrayOfStringsMapper.new
      mapper.item = [1,2,3,4]
      subj = XmlSchemaMapper::Builder.new(mapper, document.root)
      subj.build
      document.root.search('.//item').count.should eql 4
    end

    it "should raise error when don't respond to :to_xml'" do
      object.stub(not_a_mapper: 1)
      complex_element.stub(namespace: nil, reader: 'not_a_mapper')
      subject.stub(elements: [complex_element])

      expect { subject.build }.to raise_error("object of GetFirstNameMapper#not_a_mapper should respond to :to_xml")
    end

  end
end