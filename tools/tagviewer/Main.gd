extends Tree

onready var db = load("res://mesh/DataImporter.gd").new()

var nodes
var ways
var relations

func _ready():
	var data = db.load_data()
	nodes = data.nodes
	ways = data.ways
	relations = data.relations
	
	var root = create_item()
	hide_root = true
	
	create_nodes_item(nodes, root)
	create_ways_item(ways, root)
	create_relations_item(relations, root)


func create_tags_item(tags, parent, filter = ""):
	var tags_item = create_item(parent)
	tags_item.set_text(0, "tags")
	var has_filtered_tag = false
	
	for tag in tags:
		var text = "%s : %s" % [tag.k, tag.v]
		
		if not filter.empty() and not filter in text: continue
		
		var tag_item = create_item(tags_item)
		tag_item.set_text(0, text)
		has_filtered_tag = true
	
	if not has_filtered_tag:
		tags_item.free()
	
	return has_filtered_tag


func create_nodes_item(nodes, parent, filter = ""):
	var nodes_item = create_item(parent)
	nodes_item.set_text(0, "nodes")
	var has_filtered_tag = false
	
	for node in nodes:
		var node_item = create_item(nodes_item)
		node_item.set_text(0, "node: %d" % node.id)
		
		if node.has("tags"):
			var filtered = create_tags_item(node.tags, node_item, filter)
			if not filtered: node_item.free()
			else: has_filtered_tag = true
		# TODO: do I want to see empty tags item?
		# then set the has_filtered_tag in an else branch
	if not has_filtered_tag:
		nodes_item.free()
	
	return has_filtered_tag


func create_ways_item(ways, parent, filter = ""):
	var ways_item = create_item(parent)
	ways_item.set_text(0, "ways")
	var has_filtered_child = false
	
	for way in ways:
		var way_item = create_item(ways_item)
		way_item.set_text(0, "way: %d" % way.id)
		
		if way.has("tags"):
			var filtered = create_tags_item(way.tags, way_item, filter)
			if filtered: has_filtered_child = true
		
		if way.has("nodes"):
			var filtered = create_nodes_item(way.nodes, way_item, filter)
			if filtered: has_filtered_child = true
	
	if not has_filtered_child:
		ways_item.free()
	
	return has_filtered_child


func create_relations_item(relations, root, filter = ""):
	var relations_item = create_item(root)
	relations_item.set_text(0, "relations")
	var has_filtered_tag = false
	
	for relation in relations:
		var relation_item = create_item(relations_item)
		relation_item.set_text(0, "relation: %d" % relation.id)
		
		if relation.has("tags"):
			var filtered = create_tags_item(relation.tags, relation_item, filter)
			if filtered: has_filtered_tag = true
			
		if relation.has("nodes"):
			var filtered = create_nodes_item(relation.nodes, relation_item, filter)
			if filtered: has_filtered_tag = true
			
		if relation.has("ways"):
			var filtered = create_ways_item(relation.ways, relation_item, filter)
			if filtered: has_filtered_tag = true
		
		if relation.has("relations"):
			var filtered = create_relations_item(relation.relations, relation_item, filter)
			if filtered: has_filtered_tag = true
	
	if not has_filtered_tag:
		relations_item.free()
	
	return has_filtered_tag


func _on_FilterLineEdit_text_changed(new_text):
	clear()
	var root = create_item()
	hide_root = true
	create_nodes_item(nodes, root, new_text)
	create_ways_item(ways, root, new_text)
	create_relations_item(relations, root, new_text)
	
