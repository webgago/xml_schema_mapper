require "spec_helper"

describe "Parse XML" do

  context "by GetFirstNameMapper" do
    let(:xml) { File.read('spec/fixtures/instance1.xml') }

    it "should parse with XmlSchemaMapper::Parser" do
      XmlSchemaMapper::Parser.any_instance.should_receive(:parse).with(xml)
      GetFirstNameMapper.parse(xml)
    end

    it "should return instance of GetFirstNameMapper" do
      GetFirstNameMapper.parse(xml).should be_a GetFirstNameMapper
    end

    it "should lookup all elements" do
      GetFirstNameMapper.elements.should_receive(:each)
      GetFirstNameMapper.parse(xml)
    end

    context "its" do
      subject { GetFirstNameMapper.parse(xml) }
      its(:user_identifier) { should be_eql 'xoMPRY' }
      its(:filter) { should be_a FilterMapper }
      its(:'filter.age') { should eql '94' }
      its(:'filter.gender') { should eql 'male' }
      its(:is_out) { should eql 'a' }
      its(:zone) { should eql 'b' }
      its(:options) { should be_a OptionsMapper }
      its(:'options.one') { should eql 'p6E58' }
      its(:'options.two') { should eql 'Vm1sk87pkU0pE4EKKSY' }
    end
  end

  context "by AnotherNamespace::GetFirstNameMapper" do
    let(:xml) { File.read('spec/fixtures/instance1.xml') }

    it "should parse with XmlSchemaMapper::Parser" do
      XmlSchemaMapper::Parser.any_instance.should_receive(:parse).with(xml)
      AnotherNamespace::GetFirstNameMapper.parse(xml)
    end

    it "should return instance of GetFirstNameMapper" do
      AnotherNamespace::GetFirstNameMapper.parse(xml).should be_a AnotherNamespace::GetFirstNameMapper
    end

    it "should lookup all elements" do
      AnotherNamespace::GetFirstNameMapper.elements.should_receive(:each)
      AnotherNamespace::GetFirstNameMapper.parse(xml)
    end

    context "its" do
      subject { AnotherNamespace::GetFirstNameMapper.parse(xml) }
      its(:user_identifier) { should be_eql 'xoMPRY' }
      its(:filter) { should be_a AnotherNamespace::FilterMapper }
      its(:'filter.age') { should eql '94' }
      its(:'filter.gender') { should eql 'male' }
      its(:is_out) { should eql 'a' }
      its(:zone) { should eql 'b' }
      its(:options) { should be_a AnotherNamespace::OptionsMapper }
      its(:'options.one') { should eql 'p6E58' }
      its(:'options.two') { should eql 'Vm1sk87pkU0pE4EKKSY' }
    end


    context "parse arrays" do
      let(:xml) { File.read('spec/fixtures/instance_with_arrays.xml') }
      subject { ArrayNamespace::ArrayOfGetFirstNameMapper.parse(xml) }

      it do
        subject.query.should have(2).elements
        ArrayNamespace::ArrayOfGetFirstNameMapper.parse(subject.to_xml).query.should have(2).elements
      end
    end
  end

end