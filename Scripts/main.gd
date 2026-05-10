extends Node2D

@onready var container: Container = $Control/Container
@onready var ciudad: Node2D = %Ciudad
@onready var camion: Node2D = %Camion



func _on_correr_pressed() -> void:
	var matriz_distancias = ciudad.grafo
	if container.ids_incluidos.is_empty():
		push_error("No hay pedidos selecionados")
	optimizar_ruta(container.ids_incluidos, matriz_distancias)

var mejor_distancia = INF
var mejor_ruta = []
func optimizar_ruta(ids_pedidos, matriz_distancias):
	print("DEBUG ids_pedidos: ", ids_pedidos)
	print("DEBUG grafo size: ", matriz_distancias.size())
	if ids_pedidos.is_empty():
		push_error("ids_pedidos está vacío")
		return
	mejor_distancia = INF
	mejor_ruta = []
	
	var ruta_inicial= [0]
	var visitados= {0:true}
	
	backtracking(0,ids_pedidos,visitados,ruta_inicial,0,matriz_distancias)
	
	print( mejor_ruta)
	print( mejor_distancia)
	
	#para mover camion
	if mejor_ruta.size() > 0:
		var ruta_coordenadas = []
		for id_nodo in mejor_ruta:
			var pos_global = ciudad.get_node_global_pos(id_nodo)
			ruta_coordenadas.append(pos_global)
			
		#enviar ruta a camion
		if camion.has_method("viajar"):
			camion.viajar(ruta_coordenadas)
		else:
			push_error("Camion no tiene funcion 'viajar'")

func backtracking(nodo_actual, ids_pedidos, visitados, ruta_actual, distancia_acumulada, matriz_distancias):
	if distancia_acumulada >= mejor_distancia:
		return
		
	if len(visitados) == len(ids_pedidos) + 1:
		var distancia_total = distancia_acumulada + matriz_distancias[nodo_actual][0]
		if distancia_total < mejor_distancia:
			mejor_distancia = distancia_total
			mejor_ruta = ruta_actual.duplicate()
			mejor_ruta.append(0)
		return
	
	
	for i in range(len(ids_pedidos)):
		var siguiente_nodo = ids_pedidos[i]
		
		if not visitados.has(siguiente_nodo):
			visitados[siguiente_nodo] = true 
			ruta_actual.append(siguiente_nodo)
			
			backtracking(
				siguiente_nodo, 
				ids_pedidos, 
				visitados, 
				ruta_actual, 
				distancia_acumulada + matriz_distancias[nodo_actual][siguiente_nodo], 
				matriz_distancias
			)
			
			visitados.erase(siguiente_nodo) 
			ruta_actual.pop_back()
