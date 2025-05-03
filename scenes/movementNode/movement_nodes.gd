extends Node2D
class_name MovementNodes

@export var is_debug_draw = true

@onready var distances = null

@onready var paths = null
# Called when the node enters the scene tree for the first time.

func get_closest_node_to_position(click_global_position: Vector2):
	var nodes_count : int = get_child_count()
	var children = get_children()
	var result = null
	var min_distance = 100000000000.0
	for node in children:
		var distance = (click_global_position - node.global_position).length_squared()
		if distance < min_distance:
			result = node
			min_distance = distance
	return result

func get_list_of_nodes_to_get_from_a_to_b(a, b)->Array[MovementNode]:
	if a == b:
		return []
	var nodes_count : int = get_child_count()
	var children = get_children()
	var index_a = children.find(a)
	var index_b = children.find(b)
	return (paths[index_a][index_b] as Array[MovementNode]).duplicate()
	
#find custom is 4.4 feature somehow
func is_node_in_array(array: Array, node : Node2D):
	for array_element in array:
		if array_element[0] == node:
			return true
	return false 

func _ready() -> void:
	var nodes_count : int = get_child_count()
	var children = get_children()

	distances = Array()
	distances.resize(nodes_count)
	
	for i in range(0, nodes_count):
		distances[i] = Array()
	
	for i in range(0, nodes_count):
		var node : MovementNode = get_child(i) as MovementNode
		var connected_nodes = node.connected_nodes
		for j in connected_nodes:
			var index_of_j = children.find(j)
			var distance_to_node = (node.global_position - j.global_position).length()
			var dir_to = [j, distance_to_node]
			#this float comparison might be sketchy
			if !is_node_in_array(distances[i], j):
				distances[i].append(dir_to)
			var dir_from = [node, distance_to_node]
			if  !is_node_in_array(distances[index_of_j], node):
				distances[index_of_j].append(dir_from)
	for node_distances in distances:
		node_distances.sort_custom(func(a, b): return a[1] < b[1])
	
	paths = Array()
	paths.resize(nodes_count)
	paths.fill([])
	for i in range(0, nodes_count):
		found_path_from_a_to_all_vertices(i)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func found_path_from_a_to_all_vertices(index: int):
	var nodes_count : int = get_child_count()
	var children = get_children()
	
	var is_visited = Array()
	is_visited.resize(nodes_count)
	is_visited.fill(0)
	
	var distances_to_vertices = Array()
	distances_to_vertices.resize(nodes_count)
	distances_to_vertices.fill(100000000000.0)
	distances_to_vertices[index] = 0.0
	
	var backtrace = Array()
	backtrace.resize(nodes_count)
	backtrace.fill([])
	
	var paths_for_node = Array()
	paths_for_node.resize(nodes_count)
	paths_for_node.fill([])
	
	var shortest_connections = Array()
	shortest_connections.resize(nodes_count)
	shortest_connections.fill([])
	
	for i in range(0, nodes_count):
		var node_index = -1
		for j in range(0, nodes_count):
			if !is_visited[j] and (node_index == -1 || (distances_to_vertices[j] < distances_to_vertices[node_index])):
				node_index = j
		if distances_to_vertices[node_index] == 100000000000.0:
			break
		is_visited[node_index] = true
		for node in distances[node_index]:
			var index_of_connected_node = children.find(node[0])
			if distances_to_vertices[node_index] + node[1] < distances_to_vertices[index_of_connected_node]:
				distances_to_vertices[index_of_connected_node] = distances_to_vertices[node_index] + node[1]
				backtrace[index_of_connected_node] = node_index
				
	for i in range(0, nodes_count):
		if i == index:
			continue
		var path_to_node : Array[MovementNode] = [children[i]]
		var current_node = i
		while backtrace[current_node] != index:
			path_to_node.append(children[backtrace[current_node]])
			current_node = backtrace[current_node]
		path_to_node.append(children[index])
		path_to_node.reverse()
		paths_for_node[i] = path_to_node
	paths[index] = paths_for_node
	
	
	pass
	
