# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rspec', :version => 2 do
  watch(%r{^spec/fixtures/.+\.rb$}) { "spec" }
  watch(%r{^spec/.+_spec\.rb$}) { "spec" }
  watch(%r{^lib/xml_schema_mapper/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { "spec" }
end