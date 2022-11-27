class_name ArrayMeshTool

var vertices = PoolVector3Array()
var colors = PoolColorArray()
var indices = PoolIntArray()
var color = Color.gray

var _index_counter = 0


func set_color(color):
	self.color = color


func add_vertex(vertex):
	vertices.append(vertex)
	colors.append(color)


func add_index(index):
	indices.append(index)


func vertices_size():
	return vertices.size()

func commit():
	var mesh_arr = []
	
	mesh_arr.resize(Mesh.ARRAY_MAX)
	mesh_arr[Mesh.ARRAY_VERTEX] = vertices
	mesh_arr[Mesh.ARRAY_INDEX] = indices
	mesh_arr[Mesh.ARRAY_COLOR] = colors
	
	return mesh_arr


