# ============================================================================
# CONTROLADOR PRINCIPAL (MAIN.GD)
# ============================================================================
# Orquesta el flujo principal del programa:
# 1. Recibe la lista de pedidos del contenedor
# 2. Genera la ruta óptima usando algoritmo de optimización
# 3. Convierte nodos a coordenadas
# 4. Envía la ruta al camión para que la viaje
# ============================================================================

extends Node2D

# --- REFERENCIAS A OTROS NODOS: Acceso a componentes principales ---
@onready var container: Container = $Control/Container        # Gestor de pedidos
@onready var ciudad: Node2D = %Ciudad                         # Gestor de grafo y ciudad
@onready var camion: Node2D = %Camion                         # Camión que viajará

# --- PASO 1: BOTÓN "CORRER RUTA" PRESIONADO ---
# Se ejecuta cuando el usuario presiona el botón para iniciar el viaje
func _on_correr_pressed() -> void:
	# Obtener la matriz de distancias desde la ciudad
	var matriz_distancias = ciudad.grafo
	# Validar que hay pedidos seleccionados
	if container.ids_incluidos.is_empty():
		push_error("No hay pedidos selecionados")
	# Optimizar la ruta con los pedidos seleccionados
	optimizar_ruta(container.ids_incluidos, matriz_distancias)

# --- VARIABLES GLOBALES: Almacenan la mejor solución encontrada ---
var mejor_distancia = INF   # Distancia total de la mejor ruta
var mejor_ruta = []         # Secuencia de nodos de la mejor ruta

# --- PASO 5: ALGORITMO DE RUTA MÍNIMA ENTRE NODOS OBLIGATORIOS ---
# Calcula primero las distancias más cortas entre todos los nodos
# Luego optimiza el orden de los pedidos usando sólo los nodos obligatorios
# Esto evita rutas circulares inútiles y permite usar nodos intermedios correctamente
# Parámetros:
#  - ids_pedidos: lista de nodos obligatorios que deben visitarse
#  - matriz_distancias: grafo con todas las distancias
func optimizar_ruta(ids_pedidos, matriz_distancias):
	# Validar entrada
	if ids_pedidos.is_empty():
		push_error("ids_pedidos está vacío")
		return
	
	# --- VALIDACIÓN: Comprobar que existen conexiones válidas para todos los nodos ---
	var conexiones_invalidas = []
	for nodo in ids_pedidos:
		if nodo >= matriz_distancias.size():
			conexiones_invalidas.append(nodo)
		elif matriz_distancias[nodo].size() == 0:
			conexiones_invalidas.append(nodo)
	
	if not conexiones_invalidas.is_empty():
		push_error("Nodos sin datos de distancia: ", conexiones_invalidas)
		return
	
	# --- PASO 2.1: Calcular todas las distancias más cortas con Floyd-Warshall ---
	var floyd_result = floyd_warshall(matriz_distancias)
	var dist = floyd_result["dist"]
	var next = floyd_result["next"]

	# Verificar que todos los pedidos son alcanzables desde el nodo 0
	for nodo in ids_pedidos:
		if dist[0][nodo] == INF:
			push_error("No es posible alcanzar el nodo pedido desde el inicio: ", nodo)
			return
	
	# --- PASO 2.2: Resolver TSP entre nodos obligatorios usando las distancias mínimas ---
	mejor_distancia = INF
	mejor_ruta = []
	backtracking_tsp(0, ids_pedidos, {0:true}, [0], 0, dist)
	
	if mejor_ruta.is_empty() or mejor_distancia == INF:
		push_error("NO SE ENCONTRÓ RUTA VÁLIDA. Verifica que todas las distancias estén definidas correctamente.")
		print("Nodos solicitados: ", ids_pedidos)
		return
	
	# Reconstruir la ruta completa usando los caminos más cortos entre los nodos obligatorios
	var ruta_completa = [0]
	for i in range(mejor_ruta.size() - 1):
		var subruta = reconstruct_path(mejor_ruta[i], mejor_ruta[i+1], next)
		for j in range(1, subruta.size()):
			ruta_completa.append(subruta[j])
	
	# Guardar la mejor ruta como la ruta completa encontrada
	mejor_ruta = ruta_completa
	
	print("Ruta encontrada: ", mejor_ruta)
	print("Distancia total: ", mejor_distancia)
	
	# --- PASO 3: CONVERTIR NODOS A COORDENADAS ---
	var ruta_coordenadas = []
	for id_nodo in mejor_ruta:
		var pos_global = ciudad.get_node_global_pos(id_nodo)
		ruta_coordenadas.append(pos_global)
	
	if camion.has_method("viajar"):
		camion.viajar(ruta_coordenadas)
	else:
		push_error("Camion no tiene funcion 'viajar'")

# --- AUXILIAR: Floyd-Warshall para distancias mínimas y siguiente nodo ---
func floyd_warshall(matriz_distancias):
	var n = matriz_distancias.size()
	var dist = []
	var next = []
	for i in range(n):
		var fila_dist = []
		var fila_next = []
		for j in range(n):
			fila_dist.append(matriz_distancias[i][j])
			if i != j and matriz_distancias[i][j] != INF:
				fila_next.append(j)
			else:
				fila_next.append(-1)
		
		dist.append(fila_dist)
		next.append(fila_next)
	
	
	for k in range(n):
		for i in range(n):
			for j in range(n):
				if dist[i][k] + dist[k][j] < dist[i][j]:
					dist[i][j] = dist[i][k] + dist[k][j]
					next[i][j] = next[i][k]
			
		
	return {"dist": dist, "next": next}

# --- AUXILIAR: Reconstruye el camino más corto entre dos nodos ---
func reconstruct_path(start, goal, next):
	var path = []
	if next[start][goal] == -1:
		return path
	path.append(start)
	var current = start
	while current != goal:
		current = next[current][goal]
		path.append(current)
	
	return path

# --- AUXILIAR: Backtracking sobre nodos obligatorios usando distancias mínimas ---
func backtracking_tsp(nodo_actual, ids_pedidos, visitados, ruta_actual, distancia_acumulada, dist):
	if distancia_acumulada >= mejor_distancia:
		return
	
	if len(visitados) == len(ids_pedidos) + 1:
		var distancia_retorno = dist[nodo_actual][0]
		if distancia_retorno == INF:
			return
		var distancia_total = distancia_acumulada + distancia_retorno
		if distancia_total < mejor_distancia:
			mejor_distancia = distancia_total
			mejor_ruta = ruta_actual.duplicate()
			mejor_ruta.append(0)
		
		return
	
	
	for siguiente_nodo in ids_pedidos:
		if not visitados.has(siguiente_nodo):
			var distancia_siguiente = dist[nodo_actual][siguiente_nodo]
			if distancia_siguiente == INF:
				continue
			visitados[siguiente_nodo] = true
			ruta_actual.append(siguiente_nodo)
			backtracking_tsp(siguiente_nodo, ids_pedidos, visitados, ruta_actual, distancia_acumulada + distancia_siguiente, dist)
			ruta_actual.pop_back()
			visitados.erase(siguiente_nodo)
		
	
