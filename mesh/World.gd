extends Spatial

var timer_counter = 0
var nodes = []
var ways = []
var relations = []

var db = DataImporter.new("res://data/tanya.db")
var line_helper_script = preload("res://test/DebugImmediateGeometry.gd")
var gen = MeshGenerator.new(funcref(self, "add_line"), funcref(self, "add_label"))

func add_line(a, b, color):
	var ig = ImmediateGeometry.new()
	var mat = SpatialMaterial.new()
	
	mat.vertex_color_use_as_albedo = true
	mat.flags_unshaded = true
	mat.albedo_color = color
	ig.material_override = mat
	ig.set_script(line_helper_script)
	ig.draw_helper_line(a, b)
	add_child(ig)

func add_label(vector, text, color):
	var l = Label3D.new()
	l.text = text
	l.pixel_size = .07
	l.translation = vector.round() + Vector3(0, 0, -1)
	l.rotate(Vector3(1, 0, 0), -PI/2)
	l.modulate = Color(.6, 0, 0)
	add_child(l)
	pass

func _ready():
	var chunk = db.load_data()
	nodes = chunk.nodes
	ways = chunk.ways
	relations = chunk.relations
	generate_ways()
	generate_relations();


func generate_ways():
	for way in ways:
		var mesh = gen.way(way)
		$RootMesh.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINE_LOOP, mesh)


func generate_relations():
	for relation in relations:
		var relation_mesh_arr = gen.relation_mesh_arrays(relation)
		
		$RootMesh.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_POINTS, relation_mesh_arr.node_mesh_arr)
		
		for mesh_arr in relation_mesh_arr.way_mesh_arrs:
			$RootMesh.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINE_STRIP, mesh_arr)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
