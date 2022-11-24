extends ImmediateGeometry


var a = Vector3()
var b = Vector3()


func _process(delta):
	begin(Mesh.PRIMITIVE_LINE_STRIP)
	add_vertex(a)
	add_vertex(b)
	end()


func draw_helper_line(a, b):
	self.a = a
	self.b = b
