require '../src/destination_xml_parser'
require 'nokogiri'

parser = DestinationXMLParser.new('../resource/taxonomy.xml', '../resource/destinations.xml')
parser.parse
parser.select_destination_by_atlas_id '355611'