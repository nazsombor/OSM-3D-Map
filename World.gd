extends Spatial

var nodeSchene = preload("res://assets/Node.tscn")
var waySchene = preload("res://assets/Way.tscn")
var relationSchene = preload("res://assets/Relation.tscn")

var i = 0
var nodes = []
var ways = []
var relations = []

var WORLD_POSITION_LAT = 47.6040
var WORLD_POSITION_LON = 19.3690
var WORLD_DISTANCE_RATIO = 5000


func _ready():
	pass


func draw_a_way(index):
	var mesh_arr = []
	var mesh_vertices = PoolVector3Array()
	var mesh_colors = PoolColorArray()
	var mesh_indices = PoolIntArray()
	mesh_arr.resize(Mesh.ARRAY_MAX)

	for i in range(ways[index].nodes.size()):
		var node = ways[index].nodes[i]
		var v3 = Vector3(lonToMeter(node.lon), 0, latToMeter(node.lat))
		mesh_vertices.append(v3)
		match i % 4:
			0: mesh_colors.append(Color.aqua)
			1: mesh_colors.append(Color.green)
			2: mesh_colors.append(Color.red)
			3: mesh_colors.append(Color.blueviolet)
		mesh_indices.append(i)

	mesh_arr[Mesh.ARRAY_VERTEX] = mesh_vertices
	mesh_arr[Mesh.ARRAY_INDEX] = mesh_indices
	mesh_arr[Mesh.ARRAY_COLOR] = mesh_colors

	var mi = MeshInstance.new()
	var mat = SpatialMaterial.new()
	mat.vertex_color_use_as_albedo = true

	mi.mesh = ArrayMesh.new()
	mi.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINE_STRIP, mesh_arr)
	add_child(mi)

	pass

func latToMeter(lat):
	return (lat - WORLD_POSITION_LAT) * WORLD_DISTANCE_RATIO



func lonToMeter(lon):
	return (lon - WORLD_POSITION_LON) * WORLD_DISTANCE_RATIO


func _on_ImportDatabase_nodes_ready(nodes, ways, relations):
	self.nodes.append_array(nodes)
	self.ways.append_array(ways)
	self.relations.append_array(relations)


func _on_Timer_timeout():
	draw_a_way(i)
	i += 1
	pass # Replace with function body.
