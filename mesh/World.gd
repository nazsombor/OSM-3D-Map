class_name WorldMap
extends Spatial

export var debug = false
var db = DataImporter.new(debug)
var gen = MeshInstanceGenerator.new(
	funcref(self, "add_debug_line"),
	funcref(self, "add_debug_label"),
	funcref(self, "add_debug_point"))


func _ready():
	var chunk = db.load_data()
	build_chunk(chunk)


func build_chunk(chunk):
	for node in chunk.nodes:
		build_mesh(gen.node(node))
		
	for way in chunk.ways:
		build_mesh(gen.way(way))
		
	for relation in chunk.relations:
		build_mesh(gen.relation(relation))


func build_mesh(data):
	for object in data:
		add_child(object)


func add_debug_line(a, b, color):
	if not $Debug.visible: return
	var ig = ImmediateGeometry.new()
	var mat = SpatialMaterial.new()
	mat.vertex_color_use_as_albedo = true
	mat.flags_unshaded = true
	mat.albedo_color = color
	ig.material_override = mat
	ig.set_script(preload("res://test/DebugLineImmediateGeometry.gd"))
	ig.draw_helper_line(a, b)
	$Debug.add_child(ig)

func add_debug_label(vector, text, color):
	if not $Debug.visible: return
	var l = Label3D.new()
	l.text = text
	l.pixel_size = .03
	l.translation = vector.round()
	l.rotate(Vector3(1, 0, 0), -PI/2)
	l.modulate = Color(.6, 0, 0)
	$Debug.add_child(l)
	return l

func add_debug_point(vector, color):
	if not $Debug.visible: return
	var b = CSGBox.new()
	var mat = SpatialMaterial.new()
	mat.flags_unshaded = true
	mat.albedo_color = color
	b.material_override = mat
	b.translation = vector
	b.width = .05
	b.height = .05
	b.depth = .05
	$Debug.add_child(b)
