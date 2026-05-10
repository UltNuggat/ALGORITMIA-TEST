class_name Pedido
extends RefCounted

enum Tipo_pedido {NORMAL, FRAGIL, FRIO, CALIENTE}
enum Nodos_posibles {A = 1,B = 2, C = 3,D = 4,E = 5,F = 6,G = 7,H = 8}
var id: int
var tipo: Tipo_pedido
var peso: int
var precio: int
var nodo: Nodos_posibles

func _init( _id: int, _tipo: Tipo_pedido, _peso: int, _precio: int, _nodo: Nodos_posibles):
	self.id = _id
	self.tipo = _tipo
	self.peso = _peso
	self.precio = _precio
	self.nodo = _nodo

func printer():
	print("Id: " + str(id) + "|tipo: "+ str(tipo) + "|peso: "+ str(peso) + "|precio: "+ str(precio) + "|nodo "+ str(nodo))


func generar_texto_ticket() -> String:
	var tipo_nombre = Tipo_pedido.keys()[tipo]
	var nodo_nombre = Nodos_posibles.keys()[nodo - 1] 
	return "ID: %d | Tipo: %s | Peso: %d | Precio: %d | Nodo: %s\n" % [id, tipo_nombre, peso, precio, nodo_nombre]
