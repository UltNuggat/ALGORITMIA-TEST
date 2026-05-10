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

# --- PASO 2: OPTIMIZAR RUTA USANDO BACKTRACKING ---
# Encuentra la ruta de distancia mínima que visita todos los pedidos
func optimizar_ruta(ids_pedidos, matriz_distancias):
	# Debug: Mostrar datos de entrada
	print("DEBUG ids_pedidos: ", ids_pedidos)
	print("DEBUG grafo size: ", matriz_distancias.size())
	
	# Validar entrada
	if ids_pedidos.is_empty():
		push_error("ids_pedidos está vacío")
		return
	
	# Resetear variables globales
	mejor_distancia = INF
	mejor_ruta = []
	
	# --- INICIALIZACIÓN: Comenzar desde el nodo 0 (punto de salida) ---
	var ruta_inicial= [0]               # Ruta comienza en nodo 0
	var visitados= {0:true}             # Marcar nodo 0 como visitado
	
	# --- EJECUTAR ALGORITMO: Explorar todas las rutas posibles ---
	backtracking(0, ids_pedidos, visitados, ruta_inicial, 0, matriz_distancias)
	
	# Debug: Mostrar resultado
	print( mejor_ruta)
	print( mejor_distancia)
	
	# --- PASO 3: CONVERTIR NODOS A COORDENADAS ---
	if mejor_ruta.size() > 0:
		var ruta_coordenadas = []
		# Para cada nodo en la ruta, obtener sus coordenadas globales
		for id_nodo in mejor_ruta:
			var pos_global = ciudad.get_node_global_pos(id_nodo)
			ruta_coordenadas.append(pos_global)
			
		# --- PASO 4: ENVIAR RUTA AL CAMIÓN ---
		# Verificar que el camión tiene el método para viajar
		if camion.has_method("viajar"):
			camion.viajar(ruta_coordenadas)  # El camión ejecuta la ruta
		else:
			push_error("Camion no tiene funcion 'viajar'")

# --- PASO 5: ALGORITMO BACKTRACKING (FUERZA BRUTA) ---
# Explora todas las permutaciones posibles de nodos para encontrar la ruta óptima
# Parámetros:
#  - nodo_actual: nodo donde estamos actualmente
#  - ids_pedidos: lista de nodos que deben visitarse
#  - visitados: conjunto de nodos ya visitados
#  - ruta_actual: secuencia de nodos visitados hasta ahora
#  - distancia_acumulada: suma de distancias en la ruta actual
#  - matriz_distancias: grafo con todas las distancias
func backtracking(nodo_actual, ids_pedidos, visitados, ruta_actual, distancia_acumulada, matriz_distancias):
	# --- PODA 1: Si ya superamos la mejor distancia, no explorar esta rama ---
	if distancia_acumulada >= mejor_distancia:
		return
	
	# --- CONDICIÓN DE PARADA: Se han visitado todos los nodos ---
	# +1 porque incluye el nodo 0 de salida
	if len(visitados) == len(ids_pedidos) + 1:
		# Calcular distancia total cerrando la ruta (volviendo a nodo 0)
		var distancia_total = distancia_acumulada + matriz_distancias[nodo_actual][0]
		# Si es mejor que la actual, guardarla
		if distancia_total < mejor_distancia:
			mejor_distancia = distancia_total
			mejor_ruta = ruta_actual.duplicate()
			mejor_ruta.append(0)  # Agregar retorno al nodo 0
		return
	
	# --- EXPLORACIÓN: Intentar visitar cada nodo no visitado ---
	for i in range(len(ids_pedidos)):
		var siguiente_nodo = ids_pedidos[i]
		
		# Si este nodo aún no ha sido visitado
		if not visitados.has(siguiente_nodo):
			# Marcar como visitado
			visitados[siguiente_nodo] = true 
			# Agregar a la ruta actual
			ruta_actual.append(siguiente_nodo)
			
			# Recursión: Explorar desde este nuevo nodo
			backtracking(
				siguiente_nodo,  # Nuevo nodo actual
				ids_pedidos, 
				visitados, 
				ruta_actual, 
				distancia_acumulada + matriz_distancias[nodo_actual][siguiente_nodo],  # Acumular distancia
				matriz_distancias
			)
			
			# Backtrack: Deshacer cambios para intentar otra rama
			visitados.erase(siguiente_nodo) 
			ruta_actual.pop_back()
