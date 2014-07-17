class DestinationXMLParser
  def initialize taxonomy_file_name, destinations_file_name
    f = File.open(taxonomy_file_name)
    doc = Nokogiri::XML(f)
    @taxonomy_root = doc.root

    f = File.open(destinations_file_name)
    doc = Nokogiri::XML(f)
    @destinations_root = doc.root
  end

  def parse
    parseNode @taxonomy_root, 0
  end

  def parseNode root, depth
    depth += 1
    if root['atlas_node_id']
      print_atlas(depth, root)
    end
    root.children.each do |node|
      parseNode node, depth
    end
  end

  def print_atlas(depth, root)
    depth.times { print ' ' }
    print "- #{root['atlas_node_id']} "
    p "#{root.at_xpath('node_name').text}"
  end
end