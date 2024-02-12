require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'nokogiri', '1.16.0' # swap to 1.13.10 to see different behaviour
  gem 'byebug'
end

# This repo was created to help reproduce the issue seen in: https://github.com/sparklemotion/nokogiri/issues/3128
# No longer necessary in the strict sense, as the issue as described
# is not right (everything works correctly).

# Primarily the "issue" is that parsing the xml document, converting to_xml, and then parsing it again
# seemed to work fine in v1.13.0, but does not work in v1.16.0.

# However, this isn't really an "issue" as there's no need for this redundant re-parsing.
# `xml = Nokogiri::XML(xml.to_xml)` achieves nothing, and can simply be avoided, or at worst, given
# the ParseOptions (po variable) to parse correctly.

# Merely including all this for completeness of the GitHub issue


data = File.read("ase_xml/r39_p1/test_data/mdmtm_nemmco_0000000001.xml")

po = Nokogiri::XML::ParseOptions.new.huge.pedantic
xml = Nokogiri::XML::Document.parse(data, nil, nil, po)

xml = Nokogiri::XML(xml.to_xml)

Dir.chdir("ase_xml/r39_p1/schema/") do
  xsd = Nokogiri::XML::Schema(File.read("aseXML_r39_p1.xsd"))
  errors = xsd.validate(xml)
  raise StandardError.new(errors) if errors.any?
end
