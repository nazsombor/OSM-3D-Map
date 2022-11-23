var world_position_lat = 47.6040
var world_position_lon = 19.3690
var distance_ratio = 5000

func way_mesh_array(way):
	var mesh_arr = []
	var mesh_vertices = PoolVector3Array()
	var mesh_colors = PoolColorArray()
	var mesh_indices = PoolIntArray()
	mesh_arr.resize(Mesh.ARRAY_MAX)
	
	for i in range(way.nodes.size()):
		var node = way.nodes[i]
		var v3 = Vector3(lonToMeter(node.lon), 0, latToMeter(node.lat))
		mesh_vertices.append(v3)
		match i % 2:
			0: mesh_colors.append(Color.aqua)
			1: mesh_colors.append(Color.blueviolet)

		mesh_indices.append(i)
	
	mesh_arr[Mesh.ARRAY_VERTEX] = mesh_vertices
	mesh_arr[Mesh.ARRAY_INDEX] = mesh_indices
	mesh_arr[Mesh.ARRAY_COLOR] = mesh_colors
	
	return mesh_arr

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

static func road(way):
	pass

func latToMeter(lat):
	return - (lat - world_position_lat) * distance_ratio
	# Godot's z coordinate goes to south instead of north

func lonToMeter(lon):
	return (lon - world_position_lon) * distance_ratio

