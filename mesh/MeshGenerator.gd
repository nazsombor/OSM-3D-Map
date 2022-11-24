class_name MeshGenerator

var world_position_lat = 47.6040
var world_position_lon = 19.3690
var distance_ratio = 5000

# Mesh types
const HIGHWAY_RESITENTIAL = "highway-resitential"
const UNSPECIFIED = "__unspecified__"

var add_line
var add_label

func _init(add_line, add_label):
	self.add_line = add_line
	self.add_label = add_label
	
func line(a, b, color = Color.blue):
	add_line.call_func(a, b, color)

func label(vector, text = null, color = Color(.7, 0, 0)):
	if text == null: text = str(Vector2(vector.x, vector.z).round())
	add_label.call_func(vector, text, color)


func _line_intersect(aFrom, aTo, bFrom, bTo):
	# As long as there is no hight used I can use 2d math
	# The y will need to be calculated differently I guess
	var af = Vector2(aFrom.x, aFrom.z)
	var at = Vector2(aTo.x, aTo.z)
	var bf = Vector2(bFrom.x, bFrom.z)
	var bt = Vector2(bTo.x, bTo.z)
	
	var rs = Geometry.line_intersects_line_2d(af, at, bf, bt)
	
	return Vector3(rs.x, 0, rs.y)


func node_to_mesh_array(node):
	pass


func way(way):
	match type_of(way):
		HIGHWAY_RESITENTIAL: return road(way)
		UNSPECIFIED: return way_mesh_array(way)

func relation(relation):
	pass


func type_of(way):
	for tag in way.tags:
		match tag.k:
			"highway":
				match tag.v:
					"residential": return HIGHWAY_RESITENTIAL
			_: return UNSPECIFIED


func road(way, road_radius = 2.5):
	var at = ArrayMeshTool.new()
	var one_side = []
	var other_side = []
	var step = 5
	for i in range(step if step != 0 else way.nodes.size()):

		if i == 0:
			var a = vector3(way.nodes[i])
			var b = vector3(way.nodes[i + 1])
			var ab = b - a
			var abr = ab.normalized().rotated(Vector3(0, 1, 0), PI/2) * road_radius
			var x = a - abr
			var y = a + abr
			
			line(a, a + abr)
			line(a, a - abr)
			
			one_side.append(x)
			other_side.append(y)
			
		elif i == way.nodes.size() -1:
			var a = vector3(way.nodes[i])
			var b = vector3(way.nodes[i - 1])
			var ab = b - a
			var abr = ab.normalized().rotated(Vector3(0, 1, 0), PI/2) * road_radius
			line(a, a + abr)
			line(a, a - abr)
			var x = a - abr
			var y = a + abr
			
			one_side.append(x)
			other_side.append(y)
			print(x)
			print(y)
		else:
			var a = vector3(way.nodes[i - 1])
			var b = vector3(way.nodes[i])
			var c = vector3(way.nodes[i + 1])
			line(a, b)
			line(b, c)
			var ab = b - a
			var bc = c - b
			var abr = ab.normalized().rotated(Vector3(0, 1, 0), PI/2) * road_radius
			var bcr = bc.normalized().rotated(Vector3(0, 1, 0), PI/2) * road_radius
			line(b, b + bcr)
			line(b, b - bcr)
			line(a + abr, b + abr, Color.red)
			line(b + bcr, c + bcr, Color.red)
			line(a - abr, b - abr, Color.green)
			line(b - bcr, c - bcr, Color.green)
			var x = _line_intersect(a + abr, b + abr, b + bcr, c + bcr)
			var y = _line_intersect(a - abr, b - abr, b - bcr, c - bcr)
			one_side.append(x)
			other_side.append(y)
			print(x)
			print(y)
	
	print(".....")
	for i in range(0, one_side.size()):
		at.add_vertex(one_side[i])
		print(one_side[i])

	for i in range(other_side.size() - 1, -1, -1):
		at.add_vertex(other_side[i])
		print(other_side[i])
	
	
	return at.commit()


func way_mesh_array(way):
	var at = ArrayMeshTool.new()
	for i in range(way.nodes.size()):
		var v3 = vector3(way.nodes[i])
		at.add_vertex(v3)
	
	return at.commit()

func relation_mesh_arrays(relation):
	var mesh_arrs = {
		node_mesh_arr = [],
		way_mesh_arrs = []
	}
	var node_mesh_vertices = PoolVector3Array()
	var node_mesh_colors = PoolColorArray()
	var node_mesh_indices = PoolIntArray()

	mesh_arrs.node_mesh_arr.resize(Mesh.ARRAY_MAX)
	
	if relation.has("nodes"): for i in range(relation.nodes.size()):
		var v3 = Vector3(lonToMeter(relation.nodes[i].lon), 0, latToMeter(relation.nodes[i].lat))
		node_mesh_vertices.append(v3)
		node_mesh_colors.append(Color.red)
		node_mesh_indices.append(i)
	
	mesh_arrs.node_mesh_arr[Mesh.ARRAY_VERTEX] = node_mesh_vertices
	mesh_arrs.node_mesh_arr[Mesh.ARRAY_COLOR] = node_mesh_colors
	mesh_arrs.node_mesh_arr[Mesh.ARRAY_INDEX] = node_mesh_indices
	
	if relation.has("ways"): for way in relation.ways:
		mesh_arrs.way_mesh_arrs.append(way_mesh_array(way))
	
	return mesh_arrs 

func vector3(node):
	return Vector3(lonToMeter(node.lon), 0, latToMeter(node.lat))
	

func latToMeter(lat):
	return - (lat - world_position_lat) * distance_ratio
	# Godot's z coordinate goes to south instead of north

func lonToMeter(lon):
	return (lon - world_position_lon) * distance_ratio

