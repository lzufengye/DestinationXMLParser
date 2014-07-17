require '../src/destination_xml_parser'
require 'nokogiri'

parser = DestinationXMLParser.new('../resource/taxonomy.xml', '../resource/destinations.xml', 'output.txt')
parser.parse
parser.close