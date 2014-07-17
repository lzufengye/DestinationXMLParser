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
    print_history(depth, node)
    print_introductory(depth, node)
    print_practical_information(depth, node)
    print_transport(depth, node)
    print_weather(depth, node)
    print_work_live_study(depth, node)
  end

  def print_work_live_study(depth, node)
    print_tab depth+2
    print '- work_live_study'
    print_tab depth+4
    print '- work'
    print_tab depth+6
    print '- business'
    print_desgitnation_info node.at_xpath('work_live_study/work'), 'business'
    print_tab depth+6
    print '- overview'
    print_desgitnation_info node.at_xpath('work_live_study/work'), 'overview' if node
  end

  def print_weather(depth, node)
    print_tab depth+2
    print '- weather'
    print_tab depth+4
    print '- when_to_go'
    print_tab depth+6
    print '- climate'
    print_desgitnation_info node.at_xpath('weather/when_to_go'), 'climate' if node
  end

  def print_transport(depth, node)
    print_tab depth+2
    print '- transport'
    print_tab depth+4
    print '- getting_there_and_around'
    print_tab depth+6
    print '- air'
    print_desgitnation_info node.at_xpath('transport/getting_there_and_around'), 'air'
    print_tab depth+6
    print '- bicycle'
    print_desgitnation_info node.at_xpath('transport/getting_there_and_around'), 'bicycle'
    print_tab depth+6
    print '- bus_and_tram'
    print_desgitnation_info node.at_xpath('transport/getting_there_and_around'), 'bus_and_tram'
    print_tab depth+6
    print '- car_and_motorcycle'
    print_desgitnation_info node.at_xpath('transport/getting_there_and_around'), 'car_and_motorcycle'
    print_tab depth+6
    print '- local_transport'
    print_desgitnation_info node.at_xpath('transport/getting_there_and_around'), 'local_transport'
    print_tab depth+6
    print '- overview'
    print_desgitnation_info node.at_xpath('transport/getting_there_and_around'), 'overview' if node
    print_tab depth+6
    print '- train'
    print_desgitnation_info node.at_xpath('transport/getting_there_and_around'), 'train'
  end

  def print_practical_information(depth, node)
    print_tab depth+2
    print '- practical_information'
    print_tab depth+4
    print '- health_and_safety'
    print_tab depth+6
    print '- dangers_and_annoyances'
    print_desgitnation_info node.at_xpath('practical_information/health_and_safety'), 'dangers_and_annoyances'
    print_tab depth+6
    print '- while_youre_there'
    print_desgitnation_info node.at_xpath('practical_information/while_youre_there'), 'while_youre_there'
    print_tab depth+4
    print '- money_and_costs'
    print_tab depth+6
    print '- costs'
    print_desgitnation_info node.at_xpath('practical_information/money_and_costs'), 'costs'
    print_tab depth+6
    print_desgitnation_info node, 'money'
    print_tab depth+4
    print '- visas'
    print_tab depth+6
    print '- overview'
    print_desgitnation_info node.at_xpath('practical_information/visas'), 'overview' if node
  end

  def print_introductory(depth, node)
    print_tab depth+2
    print '- introductory'
    print_tab depth+4
    print '- introduction'
    print_tab depth+6
    print '- overview '
    print_desgitnation_info node.at_xpath('introductory/introduction'), 'overview' if node
  end

  def print_history(depth, node)
    print_tab depth+2
    print '- history:'
    print_tab depth+4
    print_desgitnation_info node, 'history'
  end

  def print_desgitnation_info node, title
    return unless node
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
    p ''
    depth.times { print '  ' }
  end
end