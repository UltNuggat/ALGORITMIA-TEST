# ============================================================================
# DEFINICIÓN DE CONEXIONES ENTRE NODOS (CONEXIONES.GD)
# ============================================================================
# Define las distancias desde un nodo específico hacia todos los demás nodos
# Cada nodo en la escena tendrá un script de conexiones con sus distancias
# ============================================================================

extends Node2D


@export var dist_0 = INF
@export var dist_1 = INF
@export var dist_2 = INF
@export var dist_3 = INF
@export var dist_4 = INF
@export var dist_5 = INF
@export var dist_6 = INF
@export var dist_7 = INF
@export var dist_8 = INF


var distancias =[]

# --- INICIALIZACIÓN: Construye el array de distancias en el orden correcto ---
func _ready() -> void:
	# Agrupa todas las distancias exportables en un array indexado
	distancias.append(dist_0)
	distancias.append(dist_1)
	distancias.append(dist_2)
	distancias.append(dist_3)
	distancias.append(dist_4)
	distancias.append(dist_5)
	distancias.append(dist_6)
	distancias.append(dist_7)
	distancias.append(dist_8)
