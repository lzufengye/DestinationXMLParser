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
    handle_atlas node, depth if node['atlas_node_id']
    node.children.each do |child_node|
      parse_node child_node, depth
    end
  end

  def handle_atlas node, depth
    print_atlas node, depth
    atlas_destinations = select_destination_by_atlas_id node['atlas_node_id']
    atlas_destinations.each do |destination_node|
      print_destination_node destination_node, depth + 1
    end
  end

  def print_atlas node, depth
    print_tab depth
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


  def print_destination_node node, depth
    print_tab depth
    depth += 1
    return if node.text?

    @output_file.print "- #{node.node_name}" if node.node_name
    if node.node_name == 'history'
      print_tab depth
      @output_file.print node.at_xpath('history').text.gsub(/\n/, ' ')
      return
    end
    @output_file.print node.text.gsub(/\n/, ' ') unless node.node_name
    node.children.each do |child_node|
      print_destination_node child_node, depth
    end
  end
end