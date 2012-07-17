require "spec_helper"

describe "Build XML" do

  context "by GetFirstName" do
    let(:xml) { File.read('spec/fixtures/instance1.xml') }

    context "valid data" do
      let(:object) do
        o     = Options.new
        o.one = 'one'
        o.two = 'two'

        f        = Filter.new
        f.age    = 50
        f.gender = 'male'

        g                 = GetFirstName.new
        g.user_identifier = '001'
        g.is_out          = 'a'
        g.zone            = 'b'
        g.filter          = f
        g.options         = o

        g
      end

      it "should build xml", pending: true do
        object.to_xml.should eql xml
      end
    end
  end

end