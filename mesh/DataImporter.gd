class_name DataImporter

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db
var test

signal on_load(nodes, ways, relations)

func _init(test = false):
	self.test = test
	db = SQLite.new()
	db.path = "res://data/tanya.db"
	db.open_db()


func _load_data_from_database():
	db.query("select * from nodes;")
	var nodes_query_result = db.query_result
	db.query("select * from ways;")
	var ways_query_result = db.query_result
	db.query("select * from relations;")
	var relations_query_result = db.query_result
	
	return {
		nodes_query_result = nodes_query_result,
		ways_query_result = ways_query_result,
		relations_query_result = relations_query_result
	}


func _load_data_from_test():
	var nodes_query_result = [
		{
			id = 2242643072,
			lat = 47.6044448,
			lon = 19.3695053,
			tags = null
		},
		{
			id = 2242643068,
			lat = 47.6028804,
			lon = 19.369778,
			tags = null
		},
		{
			id = 8622689676,
			lat = 47.6020004,
			lon = 19.3699275,
			tags = "{\"tags\": [{\"k\": \"direction\", \"v\": \"forward\"}, {\"k\": \"highway\", \"v\": \"stop\"} ]}"
		},
		{
			id = 493926385,
			lat = 47.6018953,
			lon = 19.3699454,
			tags = null
		},
		{
			id = 8628863462,
			lat = 47.6019841,
			lon = 19.3699303,
			tags = null
		}
	]
	var ways_query_result = [
		{
			id = 40667114,
			minLat = 47.6018953,
			minLon = 19.3695053,
			maxLat = 47.6044448,
			maxLon = 19.3699454,
			value = "{\"tags\": [{\"k\": \"highway\", \"v\": \"residential\"}, {\"k\": \"name\", \"v\": \"Tisza utca\"} ], \"nds\": [{\"ref\": 2242643072}, {\"ref\": 2242643068}, {\"ref\": 8622689676}, {\"ref\": 8628863462}, {\"ref\": 493926385} ]}"
		}
	]
	var relations_query_result = [
		
	]
	
	return {
		nodes_query_result = nodes_query_result,
		ways_query_result = ways_query_result,
		relations_query_result = relations_query_result
	}


func load_data():

	var loaded = _load_data_from_test() if test else _load_data_from_database()
	var all_nodes = []
	var unused_nodes = []
	var all_ways = []
	var unused_ways = []
	var relations = []
	
	# Only nodes that wasn't used by ways and relations
	# are submitted to the world as a separate node list
	for row in loaded.nodes_query_result:
		var node = {
			id = row.id,
			lat = row.lat,
			lon = row.lon,
			used = false
		}
		
		if row.tags != null:
			node.tags = JSON.parse(row.tags).result.tags
		
		all_nodes.append(node)
	
	# Construct ways
	for row in loaded.ways_query_result:
		var value = JSON.parse(row.value).result
		var way = {
			id = row.id,
			minLat = row.minLat,
			minLon = row.minLon,
			maxLat = row.maxLat,
			maxLon = row.maxLon,
			nodes = [],
			used = false
		}
		
		if value.has("tags"):
			way.tags = value.tags
		
		for nd in value.nds:
			for node in all_nodes:
				if nd.ref == node.id:
					way.nodes.append(node)
					node.used = true
		
		all_ways.append(way)
	
	# Construct relations part I:
	# Add relation member references
	for row in loaded.relations_query_result:
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
				for node in all_nodes:
					if nd.ref == node.id:
						relation.nodes.append(node)
						node.used = true
		
		if value.has("members"):
			for member in value.members:
				match member.type:
					"node":
						for node in all_nodes:
							if node.id == member.ref:
								relation.nodes.append(node)
								node.used = true
					"way":
						for way in all_ways:
							if way.id == member.ref:
								relation.ways.append(way)
								way.used = true
								break
					"relation":
						relation.relation_refs.append(member.ref)
		
		relations.append(relation)
	
	# Construct relations part II:
	# Find the ready relation members
	for relation in relations:
		for ref in relation.relation_refs:
			for rel in relations:
				if rel.id == ref:
					relation.relations.append(rel)
					break
		relation.erase("relation_refs")
	
	# Unused nodes
	for node in all_nodes:
		if node.used == false:
			unused_nodes.append(node)
			node.erase("used")
	
	# Unused ways
	for way in all_ways:
		if way.used == false:
			unused_ways.append(way)
			way.erase("used")
	
	return {
		nodes = unused_nodes,
		ways = unused_ways,
		relations = relations
	}

