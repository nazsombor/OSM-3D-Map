class_name MeshGenerator

var world_position_lat = 47.6040
var world_position_lon = 19.3690
var distance_ratio = 5000

var add_debug_line
var add_debug_label
var add_debug_point

const UNSPECIFIED = 0
const ROAD = 1
const FOOTWAY = 2
const BUILDING = 10
const FOREST = 30
const WATERWAY = 20


func _init(add_debug_line, add_debug_label, add_debug_point):
	self.add_debug_line = add_debug_line
	self.add_debug_label = add_debug_label
	self.add_debug_point = add_debug_point


func line(a, b, color = Color.blue):
	add_debug_line.call_func(a, b, color)


func label(vector, text = null, color = Color(.7, 0, 0)):
	if text == null: text = str(Vector2(vector.x, vector.z).round())
	add_debug_label.call_func(vector, text, color)


func point(vector, color = Color.red):
	add_debug_point.call_func(vector, color)


func nodes(nodes, color = Color.red):
	var at = ArrayMeshTool.new()
	at.set_color(color)
	for node in nodes:
		at.add_vertex(vector3(node))
	return at.commit()


func way(way):
	if not way.has("tags"): return way_mesh_array(way)
	var tags = way.tags
	var nodes = way.nodes
	
	match type(tags):
		ROAD: return road(nodes, .05)
		FOOTWAY: return road(nodes, .02)
		WATERWAY: return way_mesh_array(way)
		BUILDING: return way_mesh_array(way)
		FOREST: return way_mesh_array(way)
		_: return way_mesh_array(way)


func relation(relation):
	var tags = relation.tags
	



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


func way_mesh_array(way):
	var at = ArrayMeshTool.new()
	
	for i in range(way.nodes.size()):
		var v3 = vector3(way.nodes[i])
		at.add_vertex(v3)
		at.add_index(i)
	
	return at.commit()


func relation_mesh_arrays(relation):
	var at = ArrayMeshTool.new()
	var mesh_arrs = {
		node_mesh_arr = [],
		way_mesh_arrs = []
	}

	if relation.has("nodes"):
		for node in relation.nodes:
			var a = vector3(node)
			at.set_color(Color.red)
			at.add_vertex(a)
	
	if relation.has("ways"):
			for way in relation.ways:
				var mesh_arr = way_mesh_array(way)
				mesh_arrs.way_mesh_arrs.append(mesh_arr)
	
	return mesh_arrs 

func road(nodes, road_radius = .1):
	var at = ArrayMeshTool.new()
	var arr = []
	
	for i in range(nodes.size()):
		if i == 0:
			var a = vector3(nodes[i])
			var b = vector3(nodes[i + 1])
			var ab = b - a
			var abr = ab.normalized().rotated(Vector3(0, 1, 0), PI/2) * road_radius
			var x = a + abr
			var y = a - abr
			at.add_vertex(x)
			at.add_vertex(y)
		elif i == nodes.size() -1:
			var a = vector3(nodes[i])
			var b = vector3(nodes[i - 1])
			var ab = b - a
			var abr = ab.normalized().rotated(Vector3(0, 1, 0), PI/2) * road_radius
			var x = a - abr
			var y = a + abr
			at.add_vertex(x)
			at.add_vertex(y)
		else:
			var a = vector3(nodes[i - 1])
			var b = vector3(nodes[i])
			var c = vector3(nodes[i + 1])
			var ab = b - a
			var bc = c - b
			var abr = ab.normalized().rotated(Vector3(0, 1, 0), PI/2) * road_radius
			var bcr = bc.normalized().rotated(Vector3(0, 1, 0), PI/2) * road_radius
			var x = b + abr
			var y = b - abr
			at.add_vertex(x)
			at.add_vertex(y)
	
	for i in range(arr.size() - 2):
		if i % 2 == 0:
			at.add_index(i)
			at.add_index(i + 2)
			at.add_index(i + 1)
			pass
		else:
			at.add_index(i)
			at.add_index(i + 1)
			at.add_index(i + 2)
			pass
	
	return at.commit()




func vector3(node):
	return Vector3(lonToMeter(node.lon), 0, latToMeter(node.lat))
	

func latToMeter(lat):
	return - (lat - world_position_lat) * distance_ratio
	# Godot's z coordinate goes to south instead of north

func lonToMeter(lon):
	return (lon - world_position_lon) * distance_ratio

