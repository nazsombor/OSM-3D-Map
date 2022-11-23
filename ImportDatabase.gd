extends Node

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db
var db_name := "res://data/tanya.db"

var nodes_query_result
func get_node(id):
	for node in nodes_query_result:
		if id == node.id:
			node.used = true
			return node

signal nodes_ready(nodes, ways, relations)

func _ready():
	load_data()
	pass

func load_data():
	db = SQLite.new()
	db.path = db_name
	db.open_db()
	
	
	db.query("select * from nodes;")
	var nodes = []
	nodes_query_result = db.query_result
	db.query("select * from ways;")
	var ways = []
	var ways_query_result = db.query_result
	db.query("select * from relations;")
	var relations = []
	var relations_query_result = db.query_result
	
	for row in nodes_query_result:
		row.used = false
	
	
	for row in ways_query_result:
		var value = JSON.parse(row.value).result
		var way = {
			id = row.id,
			minLat = row.minLat,
			minLon = row.minLon,
			maxLat = row.maxLat,
			maxLon = row.maxLon,
			nodes = []
		}
		if value.has("tags"):
			way.tags = value.tags
		
		for nd in value.nds:
			way.nodes.append(get_node(nd.ref))
		
		ways.append(way)
	
	
	for row in relations_query_result:
		var value = JSON.parse(row.value).result
		var relation = {
			id = row.id,
			minLat = row.minLat,
			minLon = row.minLon,
			maxLat = row.maxLat,
			maxLon = row.maxLon,
			nodes = [],
			ways = [],
			relations = [],
			relation_refs = [],
		}
		
		if value.has("tags"):
			relation.tags = value.tags
		
		if value.has("nds"):
			for nd in value.nds:
				relation.nodes.append(get_node(nd.ref))
		
		if value.has("members"):
			for member in value.members:
				match member.type:
					"node":
						relation.nodes.append(get_node(member.ref))
					"way":
						for way in ways:
							if way.id == member.ref:
								relation.ways.append(way)
								break
					"relation":
						relation.relation_refs.append(member.ref)
		
		relations.append(relation)
	
	for relation in relations:
		for ref in relation.relation_refs:
			for rel in relations:
				if rel.id == ref:
					relation.relations.append(rel)
					break
		relation.erase("relation_refs")
	
	for node in nodes_query_result:
		if node.used == false:
			nodes.append(node)
			node.erase("used")
	db.close_db()
	emit_signal("nodes_ready", nodes, ways, relations)

