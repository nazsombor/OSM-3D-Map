class_name MeshInstanceGenerator
extends BaseMeshInstanceGenerator


func _init(add_debug_line, add_debug_label, add_debug_point) \
	.(add_debug_line, add_debug_label, add_debug_point):
	pass


func node(node):
	return [node_mesh_instance(node)]


func way(way):
	if not way.has("tags"): return [way_mesh_instance(way)]
	var tags = way.tags
	var nodes = way.nodes
	
	match type(tags):
		ROAD: return [mesh_instance(
			Mesh.PRIMITIVE_TRIANGLES,
			road(nodes, .25),
			default_material(Color.cadetblue)
		)]
		FOOTWAY: return [mesh_instance(
			Mesh.PRIMITIVE_TRIANGLES,
			road(nodes, .25),
			default_material(Color.cadetblue)
		)]
		WATERWAY: return [way_mesh_instance(way)]
		BUILDING: return [way_mesh_instance(way)]
		FOREST: return [way_mesh_instance(way)]
		_: return [way_mesh_instance(way)]


func relation(relation):
	return relation_mesh_instance_array(relation)


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
			point(x)
			point(y)
			line(a, a + ab)
			line(a, a + abr)
			line(a, a - abr)
		elif i == nodes.size() -1:
			var a = vector3(nodes[i])
			var b = vector3(nodes[i - 1])
			var ab = b - a
			var abr = ab.normalized().rotated(Vector3(0, 1, 0), PI/2) * road_radius
			var x = a - abr
			var y = a + abr
			at.add_vertex(x)
			at.add_vertex(y)
			point(x)
			point(y)
			line(a, a + ab)
			line(a, a + abr)
			line(a, a - abr)
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
			point(x)
			point(y)
			line(a, a + ab)
			line(a, a + abr)
			line(a, a - abr)
	
	for i in range(at.vertices_size() - 2):
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



