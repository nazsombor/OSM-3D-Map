extends Spatial

var timer_counter = 0
var nodes = []
var ways = []
var relations = []



var db = preload("res://DataImporter.gd").new("res://data/tanya.db")
var gen = preload("res://MeshGenerator.gd").new()

func _ready():
	var chunk = db.load_data()
	nodes = chunk.nodes
	ways = chunk.ways
	relations = chunk.relations
	generate_ways()
	generate_relations();


func generate_ways():
	for way in ways:
		var mesh_arr = gen.way_mesh_array(way)
		$RootMesh.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINE_STRIP, mesh_arr)


func generate_relations():
	for relation in relations:
		var relation_mesh_arr = gen.relation_mesh_arrays(relation)
		
		$RootMesh.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_POINTS, relation_mesh_arr.node_mesh_arr)
		
		for mesh_arr in relation_mesh_arr.way_mesh_arrs:
			$RootMesh.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINE_STRIP, mesh_arr)

