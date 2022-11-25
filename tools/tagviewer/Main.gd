extends VBoxContainer

onready var db = load("res://mesh/DataImporter.gd").new()

var nodes
var ways
var relations


func _ready():
	var data = db.load_data()
	nodes = data.nodes
	ways = data.ways
	relations = data.relations


func _on_ButtonWayTags_pressed():
	var tags = tags(ways)
	set_tag_list_items(tags)


func _on_ButtonRelationTags_pressed():
	var tags = tags(relations)
	set_tag_list_items(tags)


func tags(parent):
	var tags = {}
	for child in parent:
		if not child.has("tags"): continue
		
		for tag in child.tags:
			if not tags.has(tag.k):
				tags[tag.k] = {}
			
			if not tags[tag.k].has(tag.v):
				tags[tag.k][tag.v] = 0
			
			tags[tag.k][tag.v] += 1
	return tags


func set_tag_list_items(tags):
	$ItemList.clear()
	for key in tags.keys():
		for value in tags[key].keys():
			var text = key + " : " + value + "(" + str(tags[key][value]) + ")"
			$ItemList.add_item(text)
	print("tags added")
