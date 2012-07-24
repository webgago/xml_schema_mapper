require "spec_helper"

describe "Build XML" do

  context "by GetFirstName" do
    let(:xml) { File.read('spec/fixtures/get_first_name.xml') }

    context "valid data" do
      let(:object) do
        o     = OptionsMapper.new
        o.one = 'one'
        o.two = 'two'

        f        = FilterMapper.new
        f.age    = 50
        f.gender = 'male'

        g                 = GetFirstNameMapper.new
        g.user_identifier = '001'
        g.is_out          = 'a'
        g.zone            = 'b'
        g.filter          = f
        g.options         = o

        g
      end

      it "should build xml" do
        object.to_xml.should eql xml
      end
    end
  end

end