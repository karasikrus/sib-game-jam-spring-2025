extends Node2D
class_name MovementNode
@export var connected_nodes : Array[MovementNode] = []
var connected_nodes_distances
@onready var debug_name = $DebugName
@onready var parent_node = $".."

@export var is_available = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if parent_node.is_debug_draw:
		debug_name.append_text(name)
		for node in connected_nodes:
			if node == null:
				continue
			var line = Line2D.new()
			line.default_color = Color.WHITE
			line.add_point(to_local(position))
			line.add_point(to_local(node.position))
			line.width = 1
			add_child(line)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
