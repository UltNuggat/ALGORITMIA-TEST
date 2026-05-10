# ============================================================================
# GESTOR DE CIUDAD Y GRAFO (CIUDAD.GD)
# ============================================================================
# Construye la matriz de distancias (grafo) desde todos los nodos de conexiones
# Almacena las posiciones de los nodos para calcular rutas de viaje
# ============================================================================

extends Node2D

# --- REFERENCIAS: Nodos hijo que contienen los puntos de la ciudad ---
@onready var nodos: Node2D = $Nodos

# --- ESTRUCTURA DE DATOS DEL GRAFO ---
var grafo = []        # Matriz de adyacencia: [nodo][distancia_a_otro_nodo]
var nodos_pos=[]      # Posiciones locales de cada nodo en la escena

# --- INICIALIZACIÓN: Construye el grafo y almacena posiciones ---
# Se ejecuta cuando la escena está lista
func _ready() -> void:
	# Limpiar datos previos
	grafo.clear()
	nodos_pos.clear()
	
	# Iterar sobre cada nodo hijo y recopilar sus conexiones y posición
	for nodo in nodos.get_children():
		# Agregar la fila de distancias de este nodo al grafo
		grafo.append(nodo.distancias)
		# Almacenar la posición local del nodo
		nodos_pos.append(nodo.position)
		# Debug: Mostrar las distancias en consola
		print(nodo.distancias)

# --- MÉTODO: Convierte coordenada local a global usando el índice del nodo ---
# Parámetros: index - índice del nodo (0-8)
# Retorna: Vector2 con la posición global del nodo en la pantalla
func get_node_global_pos(index:int)-> Vector2:
	# Validar que el índice esté dentro del rango de nodos
	if index< nodos_pos.size():
		# Convertir posición local a global
		return to_global(nodos_pos[index])
	# Si el índice es inválido, retornar origen
	return Vector2.ZERO
