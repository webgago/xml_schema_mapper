require "spec_helper"

describe "Parse XML" do

  context "by GetFirstName" do
    let(:xml) { File.read('spec/fixtures/instance1.xml') }

    it "should parse with XmlSchemaMapper::Parser" do
      XmlSchemaMapper::Parser.any_instance.should_receive(:parse).with(xml)
      GetFirstName.parse(xml)
    end

    it "should return instance of GetFirstName" do
      GetFirstName.parse(xml).should be_a GetFirstName
    end

    it "should lookup all elements" do
      GetFirstName.elements.should_receive(:each)
      GetFirstName.parse(xml)
    end

    context "its" do
      subject { GetFirstName.parse(xml) }
      its(:user_identifier) { should be_eql 'xoMPRY' }
      its(:filter) { should be_a Filter }
      its(:'filter.age') { should eql '94' }
      its(:'filter.gender') { should eql 'male' }
      its(:is_out) { should eql 'a' }
      its(:zone) { should eql 'b' }
      its(:options) { should be_a Options }
      its(:'options.one') { should eql 'p6E58' }
      its(:'options.two') { should eql 'Vm1sk87pkU0pE4EKKSY' }
    end
  end

end