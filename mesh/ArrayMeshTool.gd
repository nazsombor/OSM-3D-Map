class_name ArrayMeshTool

var vertices = PoolVector3Array()
var colors = PoolColorArray()
var indices = PoolIntArray()
var color_list = [
	Color(.1, .1, .1),
	Color(.3, .3, .3),
	Color(.5, .5, .5),
	Color(.7, .7, .7),
	Color(.9, .9, .9)
]
var _index_counter = 0


func set_color(color):
	self.color = color


func add_vertex(vertex):
	vertices.append(vertex)
	indices.append(_index_counter)
	colors.append(color_list[_index_counter % color_list.size()])
	_index_counter += 1


func commit():
	var mesh_arr = []
	
	mesh_arr.resize(Mesh.ARRAY_MAX)
	mesh_arr[Mesh.ARRAY_VERTEX] = vertices
	mesh_arr[Mesh.ARRAY_INDEX] = indices
	mesh_arr[Mesh.ARRAY_COLOR] = colors
	
	return mesh_arr


