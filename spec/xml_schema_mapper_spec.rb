require "spec_helper"

describe XmlSchemaMapper do

  context "valid mapping" do
    subject { GetFirstName.new }

    it "should be XmlSchemaMapper" do
      subject.should be_a XmlSchemaMapper
    end

    its(:_schema) { should be_a LibXML::XML::Schema }
    its(:_type) { should be_a LibXML::XML::Schema::Type }
    its(:'_type.name') { should eql 'GetFirstName' }
    its(:'_type.namespace') { should eql 'http://example.com/UserService/type/' }

    its(:element_names) { should eql %w(userIdentifier filter isOut zone options) }
  end

  context "not valid mapping" do
    let(:klass) { Class.new { include XmlSchemaMapper } }

    it "should raise error" do
      expect { klass.type "Bla" }.to raise_error %Q{call "schema 'path/to/your/File.xsd'" before calling "type"}
    end
  end

end