extends Node2D
@onready var nodos: Node2D = $Nodos

var grafo = []
var nodos_pos=[]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grafo.clear()
	nodos_pos.clear()
	
	for nodo in nodos.get_children():
		grafo.append(nodo.distancias)
		nodos_pos.append(nodo.position)
		print(nodo.distancias)

func get_node_global_pos(index:int)-> Vector2:
	if index< nodos_pos.size():
		return to_global(nodos_pos[index])
	return Vector2.ZERO
