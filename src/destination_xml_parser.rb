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
    parse_node @taxonomy_root, 0
  end

  def select_destination_by_atlas_id atlas_id
    results = []
    @destinations_root.xpath("destination").each do |child_node|
      results << child_node if child_node['atlas_id'] == atlas_id
    end
    results
  end

  private
  def parse_node node, depth
    depth += 1
    handle_atlas(depth, node) if node['atlas_node_id']
    node.children.each do |child_node|
      parse_node child_node, depth
    end
  end

  def handle_atlas(depth, node)
    print_atlas(depth, node)

    atlas_destinations = select_destination_by_atlas_id node['atlas_node_id']
    atlas_destinations.each do |destination_node|
      print_destination 0, destination_node
    end
  end

  def print_destination(depth, node)
    print_desgitnation_info node
  end

  def print_desgitnation_info node
    p node.at_xpath('history').text if node.at_xpath('history')
  end

  def print_atlas(depth, node)
    depth.times { print '  ' }
    print "- #{node['atlas_node_id']} "
    p "#{node.at_xpath('node_name').text}"
  end
end