extends MeshInstance

func _ready():
	array_mesh()


func array_mesh():
	var mesh_arr = []
	var mesh_colors = PoolColorArray()
	var mesh_vertices = PoolVector3Array()
	var mesh_indices = PoolIntArray()
	mesh_arr.resize(Mesh.ARRAY_MAX)
	
	mesh_vertices.append(Vector3(0, 0, 0))
	mesh_colors.append(Color.blue)
	mesh_indices.append(0)
	
	mesh_vertices.append(Vector3(1, 0, 1))
	mesh_colors.append(Color.green)
	mesh_indices.append(1)
	
	mesh_vertices.append(Vector3(2, 0, 2))
	mesh_colors.append(Color.red)
	mesh_indices.append(2)
	
	mesh_vertices.append(Vector3(3, 0, 3))
	mesh_colors.append(Color.blue)
	mesh_indices.append(3)
	
	mesh_vertices.append(Vector3(4, 0, 4))
	mesh_colors.append(Color.green)
	mesh_indices.append(4)
	
	mesh_vertices.append(Vector3(5, 0, 5))
	mesh_colors.append(Color.red)
	mesh_indices.append(5)
	
	mesh_arr[Mesh.ARRAY_VERTEX] = mesh_vertices
	mesh_arr[Mesh.ARRAY_INDEX] = mesh_indices
	mesh_arr[Mesh.ARRAY_COLOR] = mesh_colors
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINE_STRIP, mesh_arr)
	var mat = SpatialMaterial.new()
	mat.vertex_color_use_as_albedo = true
	material_override = mat
	
	
func surface_tool():
	var st = SurfaceTool.new()
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.add_vertex(Vector3(-1, -1, 0))
	st.add_vertex(Vector3(0, 1, 0))
	st.add_vertex(Vector3(1, -1, 0))
	
	st.generate_normals()
	st.generate_tangents()
	
	mesh = st.commit()
