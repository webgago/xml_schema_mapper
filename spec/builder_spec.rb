require "spec_helper"

describe XmlSchemaMapper::Builder do
  let(:object) do
    o = Options.new; o.one = 'one'; o.two = 'two'
    f = Filter.new; f.age = 50; f.gender = 'male'
    g = GetFirstName.new; g.user_identifier = '001'; g.is_out = 'a'; g.zone = 'b'; g.filter = f; g.options = o
    g
  end

  subject { XmlSchemaMapper::Builder.new(object) }

  context 'after initialize' do
    its(:source) { should be object }
    its(:'document.to_xml') { should eql "<?xml version=\"1.0\"?>\n<getFirstName xmlns:cm=\"http://example.com/common/\" xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" xmlns:tns=\"http://example.com/UserService/type/\"/>\n" }
    its(:namespaces) { should eql 'cm' => "http://example.com/common/",
                                  'xs' => "http://www.w3.org/2001/XMLSchema",
                                  'tns' => "http://example.com/UserService/type/" }
  end

  context 'on build' do
    it "should create elements" do
      subject.stub(:add_node)
      subject.should_receive(:create_element).exactly(5).times
      subject.build
    end

    it "should add nodes to root of document" do
      subject.should_receive(:add_node).exactly(5).times
      subject.build
    end

    it "should get data from source" do
      subject.source.should_receive(:user_identifier).and_return(1)
      subject.build.to_xml.should include "<userIdentifier>1</userIdentifier>"
    end

    it "should builded xml" do
      subject.build.to_xml.should eql File.read('spec/fixtures/get_first_name.xml')
    end

  end

end