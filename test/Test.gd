extends MeshInstance

var at = ArrayMeshTool.new()

func _ready():
	array_mesh()


func array_mesh():
	at.set_color(Color.blue)
	
	at.add_vertex(Vector3(0, 0, 0))
	at.add_vertex(Vector3(1, 0, 1))
	at.add_vertex(Vector3(2, 0, 2))
	at.add_vertex(Vector3(3, 0, 3))
	at.add_vertex(Vector3(4, 0, 4))
	at.add_vertex(Vector3(5, 0, 5))
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINE_STRIP, at.commit())

	
	
func surface_tool():
	var st = SurfaceTool.new()
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	st.add_color(Color.blue)
	st.add_vertex(Vector3(-1, -1, 0))
	st.add_color(Color.green)
	st.add_vertex(Vector3(-1, 1, 0))
	st.add_color(Color.blue)
	st.add_vertex(Vector3(1, 1, 0))

	st.index()

	mesh = st.commit()
