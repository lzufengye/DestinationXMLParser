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
      print_destination depth, destination_node
    end
  end

  def print_destination(depth, node)
    print_tab depth+2
    print '- history:'
    print_tab depth+4
    print_desgitnation_info node, 'history'
    p ''

    print_tab depth+2
    print '- introductory'
    p ''
    print_tab depth+4
    print '- introduction'
    p ''
    print_tab depth+6
    print '- overview '
    print_desgitnation_info node, 'overview'
    p ''

    print '- practical_information'
      print '- health_and_safety'
        print_desgitnation_info node, 'dangers_and_annoyances'
        print_desgitnation_info node, 'while_youre_there'
      print '- money_and_costs'
        print_desgitnation_info node, 'costs'
        print_desgitnation_info node, 'money'
      print 'visas'
        print_desgitnation_info node, 'overview'
    print 'transport'
      print 'getting_there_and_around'
        print_desgitnation_info node, 'air'
        print_desgitnation_info node, 'bicycle'
        print_desgitnation_info node, 'bus_and_tram'
        print_desgitnation_info node, 'car_and_motorcycle'
        print_desgitnation_info node, 'local_transport'
        print_desgitnation_info node, 'overview'
        print_desgitnation_info node, 'train'
    print 'weather'
      print 'when_to_go'
        print_desgitnation_info node, 'climate'
    print 'work_live_study'
      print 'work'
        print_desgitnation_info node, 'business'
        print_desgitnation_info node, 'overview'

    p ''
  end

  def print_desgitnation_info node, title
    p node.at_xpath(title).text if node.at_xpath(title)
  end

  def print_atlas(depth, node)
    depth.times { print '  ' }
    print "- #{node['atlas_node_id']} "
    p "#{node.at_xpath('node_name').text}"
  end


  def select_destination_by_atlas_id atlas_id
    results = []
    @destinations_root.xpath("destination").each do |child_node|
      results << child_node if child_node['atlas_id'] == atlas_id
    end
    results
  end

  def print_tab depth
    depth.times { print '  ' }
  end
end