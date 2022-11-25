extends Tree

onready var db = load("res://mesh/DataImporter.gd").new()
var data

func _ready():
	data = db.load_data()
	
	var root = create_item()
	hide_root = true
	
	create_nodes_item(data.nodes, root)
	create_ways_item(data.ways, root)
	create_relations_item(data.relations, root)


func create_tags_item(tags, parent):
	var tags_item = create_item(parent)
	tags_item.set_text(0, "tags")
	
	for tag in tags:
		var text = "%s : %s" % [tag.k, tag.v]
		var tag_item = create_item(tags_item)
		tag_item.set_text(0, text)


func create_nodes_item(nodes, parent):
	var nodes_item = create_item(parent)
	nodes_item.set_text(0, "nodes")
	
	for node in nodes:
		var node_item = create_item(nodes_item)
		node_item.set_text(0, "node: %d" % node.id)
		
		if node.has("tags"):
			create_tags_item(node.tags, node_item)


func create_ways_item(ways, parent):
	var ways_item = create_item(parent)
	ways_item.set_text(0, "ways")
	
	for way in ways:
		var way_item = create_item(ways_item)
		way_item.set_text(0, "way: %d" % way.id)
		
		if way.has("tags"):
			create_tags_item(way.tags, way_item)
		
		if way.has("nodes"):
			create_nodes_item(way.nodes, way_item)


func create_relations_item(relations, root):
	var relations_item = create_item(root)
	relations_item.set_text(0, "relations")
	
	for relation in relations:
		var relation_item = create_item(relations_item)
		relation_item.set_text(0, "relation: %d" % relation.id)
		
		if relation.has("tags"):
			create_tags_item(relation.tags, relation_item)
			
		if relation.has("nodes"):
			create_nodes_item(relation.nodes, relation_item)
			
		if relation.has("ways"):
			create_ways_item(relation.ways, relation_item)
		
		if relation.has("relations"):
			create_relations_item(relation.relations, relation_item)


func _on_FilterLineEdit_text_changed(new_text):
	clear()
	var root = create_item()
	hide_root = true
	
	var filtered = filter(new_text)
	
	create_nodes_item(filtered.nodes, root)
	create_ways_item(filtered.ways, root)
	create_relations_item(filtered.relations, root)


func filter(filter: String):
	if filter.empty(): return data
	return {
		nodes = filter_nodes(data.nodes, filter),
		ways = filter_ways(data.ways, filter),
		relations = filter_relations(data.relations, filter)
	}
	


func tags_contain_text(tags, filter):
	for tag in tags:
		var text = "%s : %s" % [tag.k, tag.v]
		if filter in text:
			return true
	
	return false


func filter_nodes(nodes, filter):
	var filtered = []
	for node in nodes:
		if not node.has("tags"):
			continue
		if tags_contain_text(node.tags, filter):
			filtered.append(node)
	
	return filtered


func filter_ways(ways, filter):
	var filtered = []
	for way in ways:
		var filtered_nodes = filter_nodes(way.nodes, filter)
		var way_tags_are_containing_text = false
		
		if way.has("tags"):
			way_tags_are_containing_text = tags_contain_text(way.tags, filter)
		
		if not filtered_nodes.empty() or way_tags_are_containing_text:
			filtered.append(way)
	
	return filtered


func filter_relations(relations, filter, is_child_relation = false):
	var filtered = []
	for relation in relations:
		var filtered_nodes = []
		var filtered_ways = []
		var filtered_relations = []
		var relation_tags_are_containing_text = false
		
		if relation.has("tags"):
			relation_tags_are_containing_text = tags_contain_text(relation.tags, filter)
		
		if relation.has("nodes"):
			filtered_nodes.append_array(filter_nodes(relation.nodes, filter))
		
		if relation.has("ways"):
			filtered_ways.append_array(filter_ways(relation.ways, filter))
		
		if relation.has("relations"):
			filtered_relations.append_array(filter_relations(relation.relations, filter, true))
		
		if relation_tags_are_containing_text \
			or not filtered_nodes.empty() \
			or not filtered_ways.empty() \
			or not filtered_relations.empty():
				filtered.append(relation)
	
	return filtered
