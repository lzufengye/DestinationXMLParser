class DestinationXMLParser
  def initialize taxonomy_file_name, destinations_file_name, out_put_file_name
    @input_taxonomy_file = File.open(taxonomy_file_name)
    @taxonomy_doc = Nokogiri::XML(@input_taxonomy_file)
    @taxonomy_root = @taxonomy_doc.root

    @input_destinations_file = File.open(destinations_file_name)
    @destinations_doc = Nokogiri::XML(@input_destinations_file)
    @destinations_root = @destinations_doc.root

    @output_file = File.open(out_put_file_name, 'w+')
  end

  def parse
    parse_node @taxonomy_root, 0
  end

  def close
    @input_taxonomy_file.close
    @input_destinations_file.close
    @output_file.close
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
    @output_file.print '- work_live_study'
    print_tab depth+4
    @output_file.print '- work'
    print_tab depth+6
    @output_file.print '- business'
    print_desgitnation_info node.at_xpath('work_live_study/work'), 'business'
    print_tab depth+6
    @output_file.print '- overview'
    print_desgitnation_info node.at_xpath('work_live_study/work'), 'overview' if node
  end

  def print_weather(depth, node)
    print_tab depth+2
    @output_file.print '- weather'
    print_tab depth+4
    @output_file.print '- when_to_go'
    print_tab depth+6
    @output_file.print '- climate'
    print_desgitnation_info node.at_xpath('weather/when_to_go'), 'climate' if node
  end

  def print_transport(depth, node)
    print_tab depth+2
    @output_file.print '- transport'
    print_tab depth+4
    @output_file.print '- getting_there_and_around'
    print_tab depth+6
    @output_file.print '- air'
    print_desgitnation_info node.at_xpath('transport/getting_there_and_around'), 'air'
    print_tab depth+6
    @output_file.print '- bicycle'
    print_desgitnation_info node.at_xpath('transport/getting_there_and_around'), 'bicycle'
    print_tab depth+6
    @output_file.print '- bus_and_tram'
    print_desgitnation_info node.at_xpath('transport/getting_there_and_around'), 'bus_and_tram'
    print_tab depth+6
    @output_file.print '- car_and_motorcycle'
    print_desgitnation_info node.at_xpath('transport/getting_there_and_around'), 'car_and_motorcycle'
    print_tab depth+6
    @output_file.print '- local_transport'
    print_desgitnation_info node.at_xpath('transport/getting_there_and_around'), 'local_transport'
    print_tab depth+6
    @output_file.print '- overview'
    print_desgitnation_info node.at_xpath('transport/getting_there_and_around'), 'overview' if node
    print_tab depth+6
    @output_file.print '- train'
    print_desgitnation_info node.at_xpath('transport/getting_there_and_around'), 'train'
  end

  def print_practical_information(depth, node)
    print_tab depth+2
    @output_file.print '- practical_information'
    print_tab depth+4
    @output_file.print '- health_and_safety'
    print_tab depth+6
    @output_file.print '- dangers_and_annoyances'
    print_desgitnation_info node.at_xpath('practical_information/health_and_safety'), 'dangers_and_annoyances'
    print_tab depth+6
    @output_file.print '- while_youre_there'
    print_desgitnation_info node.at_xpath('practical_information/while_youre_there'), 'while_youre_there'
    print_tab depth+4
    @output_file.print '- money_and_costs'
    print_tab depth+6
    @output_file.print '- costs'
    print_desgitnation_info node.at_xpath('practical_information/money_and_costs'), 'costs'
    print_tab depth+6
    print_desgitnation_info node, 'money'
    print_tab depth+4
    @output_file.print '- visas'
    print_tab depth+6
    @output_file.print '- overview'
    print_desgitnation_info node.at_xpath('practical_information/visas'), 'overview' if node
  end

  def print_introductory(depth, node)
    print_tab depth+2
    @output_file.print '- introductory'
    print_tab depth+4
    @output_file.print '- introduction'
    print_tab depth+6
    @output_file.print '- overview '
    print_desgitnation_info node.at_xpath('introductory/introduction'), 'overview' if node
  end

  def print_history(depth, node)
    print_tab depth+2
    @output_file.print '- history:'
    print_tab depth+4
    print_desgitnation_info node, 'history'
  end

  def print_desgitnation_info node, title
    return unless node
    @output_file.print node.at_xpath(title).text.sub(/\n\n\n/, '') if node.at_xpath(title)
  end

  def print_atlas(depth, node)
    depth.times { @output_file.print '  ' }
    @output_file.print "- #{node['atlas_node_id']} "
    @output_file.puts "#{node.at_xpath('node_name').text}"
  end


  def select_destination_by_atlas_id atlas_id
    results = []
    @destinations_root.xpath("destination").each do |child_node|
      results << child_node if child_node['atlas_id'] == atlas_id
    end
    results
  end

  def print_tab depth
    @output_file.puts ''
    depth.times { @output_file.print '  ' }
  end
end