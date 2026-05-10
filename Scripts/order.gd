# ============================================================================
# CLASE PEDIDO (ORDER.GD)
# ============================================================================
# Define la estructura de un pedido con sus atributos y métodos
# Cada pedido tiene: ID, tipo, peso, precio y nodo de destino
# ============================================================================

class_name Pedido
extends RefCounted

# --- ENUMERACIONES: Tipos de pedidos y ubicaciones disponibles ---
enum Tipo_pedido {NORMAL, FRAGIL, FRIO, CALIENTE}
enum Nodos_posibles {A = 1,B = 2, C = 3,D = 4,E = 5,F = 6,G = 7,H = 8}

# --- ATRIBUTOS del pedido ---
var id: int              # Identificador único del pedido
var tipo: Tipo_pedido    # Tipo de pedido (afecta espacios en el camión)
var peso: int            # Peso del pedido (usado en algoritmo mochila)
var precio: int          # Precio/beneficio del pedido (optimizar en mochila)
var nodo: Nodos_posibles # Nodo de destino del pedido

# --- CONSTRUCTOR: Inicializa un pedido con todos sus parámetros ---
func _init( _id: int, _tipo: Tipo_pedido, _peso: int, _precio: int, _nodo: Nodos_posibles):
	self.id = _id
	self.tipo = _tipo
	self.peso = _peso
	self.precio = _precio
	self.nodo = _nodo

# --- MÉTODO: Imprime los datos del pedido en consola para debugging ---
func printer():
	print("Id: " + str(id) + "|tipo: "+ str(tipo) + "|peso: "+ str(peso) + "|precio: "+ str(precio) + "|nodo "+ str(nodo))

# --- MÉTODO: Genera texto formateado del pedido para mostrar en ticket ---
func generar_texto_ticket() -> String:
	var tipo_nombre = Tipo_pedido.keys()[tipo]
	var nodo_nombre = Nodos_posibles.keys()[nodo - 1] 
	return "ID: %d | Tipo: %s | Peso: %d | Precio: %d | Nodo: %s\n" % [id, tipo_nombre, peso, precio, nodo_nombre]
