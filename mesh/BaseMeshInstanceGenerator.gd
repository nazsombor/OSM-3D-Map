class_name BaseMeshInstanceGenerator

var world_position_lat = 47.6040
var world_position_lon = 19.3690
var distance_ratio = 5000

var add_debug_line
var add_debug_label
var add_debug_point


func _init(add_debug_line, add_debug_label, add_debug_point):
	self.add_debug_line = add_debug_line
	self.add_debug_label = add_debug_label
	self.add_debug_point = add_debug_point


const UNSPECIFIED = 0
const ROAD = 1
const FOOTWAY = 2
const BUILDING = 10
const FOREST = 30
const WATERWAY = 20


func type(tags):
	for tag in tags:
		match tag.k:
			"highway":
				match tag.v:
					"residential": return ROAD
					"unclassified": return ROAD
					"track": return ROAD
					"service": return ROAD
					"footway": return FOOTWAY
					"path": return FOOTWAY
			"waterway": return WATERWAY
			"building": return BUILDING
			"landuse":
				match tag.v:
					"forest": return FOREST
					_: return UNSPECIFIED
			_: return UNSPECIFIED


func line(a, b, color = Color.blue):
	add_debug_line.call_func(a, b, color)


func label(vector, text = null, color = Color(.7, 0, 0)):
	if text == null: text = str(Vector2(vector.x, vector.z).round())
	add_debug_label.call_func(vector, text, color)


func point(vector, color = Color.red):
	add_debug_point.call_func(vector, color)


func vector3(node):
	return Vector3(lonToMeter(node.lon), 0, latToMeter(node.lat))


func latToMeter(lat):
	return - (lat - world_position_lat) * distance_ratio
	# Godot's z coordinate goes to south instead of north


func lonToMeter(lon):
	return (lon - world_position_lon) * distance_ratio


func default_material(color = Color.cadetblue):
	var mat = SpatialMaterial.new()
	mat.flags_unshaded = true
	mat.albedo_color = color
	return mat


func mesh_instance(render_type, mesh_arr, material):
	var mi = MeshInstance.new()
	var arr_mesh = ArrayMesh.new()
	mi.mesh = arr_mesh
	mi.material_override = material
	arr_mesh.add_surface_from_arrays(render_type, mesh_arr)
	#TODO: set arr_mesh material instead of override
	return mi


func node_mesh_instance(node):
	var at = ArrayMeshTool.new()
	at.add_vertex(vector3(node))
	# A node might be a tree. (Tree is not a good example, but a complex object for sure)
	# That would have a trunk MeshInstance and a leafage MeshInstance.
	# Thus the return type must be an Array
	return mesh_instance(
			Mesh.PRIMITIVE_POINTS,
			at.commit(),
			default_material(Color.red))


func way_mesh_instance(way):
	var at = ArrayMeshTool.new()
	
	for i in range(way.nodes.size()):
		var a = vector3(way.nodes[i])
		at.add_vertex(a)
		at.add_index(i)
	
	return mesh_instance(
			Mesh.PRIMITIVE_LINE_STRIP,
			at.commit(),
			default_material(Color.dimgray))
	


func relation_mesh_instance_array(relation):
	var at = ArrayMeshTool.new()
	var mesh_instances = []
	var nodes_mesh_arr
	var ways_mesh_instances
	
	if relation.has("nodes"):
		for node in relation.nodes:
			mesh_instances.append(node_mesh_instance(node))

	if relation.has("ways"):
		for way in relation.ways:
			mesh_instances.append(way_mesh_instance(way))
	
	if relation.has("relations"):
		for rel in relation.relations:
			mesh_instances.append_array(relation_mesh_instance_array(rel))

	return mesh_instances
