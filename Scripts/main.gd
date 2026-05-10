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
	print("\n" + "============================================================")
	print("INICIANDO OPTIMIZACIÓN DE RUTA")
	print("============================================================")
	print("Nodos a visitar (ids_pedidos): ", ids_pedidos)
	print("Tamaño del grafo: ", matriz_distancias.size(), " nodos")
	
	# --- VALIDACIÓN: Verificar que la matriz de distancias es válida ---
	if matriz_distancias.is_empty():
		push_error("La matriz de distancias está vacía")
		return
	
	# Validar entrada
	if ids_pedidos.is_empty():
		push_error("ids_pedidos está vacío")
		return
	
	# --- DEBUG: Mostrar todas las distancias de la matriz ---
	print("\nMatriz de distancias completa:")
	for i in range(matriz_distancias.size()):
		print("Nodo ", i, ": ", matriz_distancias[i])
	
	# --- VALIDACIÓN: Comprobar que existen conexiones válidas para todos los nodos ---
	var conexiones_invalidas = []
	for nodo in ids_pedidos:
		print("\nValidando nodo ", nodo)
		if nodo >= matriz_distancias.size():
			print("  ERROR: Nodo ", nodo, " está fuera del rango (max: ", matriz_distancias.size()-1, ")")
			conexiones_invalidas.append(nodo)
		elif nodo < 0:
			print("  ERROR: Nodo ", nodo, " es negativo")
			conexiones_invalidas.append(nodo)
		else:
			print("  OK: Nodo ", nodo, " existe en el grafo")
			if matriz_distancias[nodo].size() == 0:
				print("  ERROR: Nodo ", nodo, " tiene 0 distancias")
				conexiones_invalidas.append(nodo)
			else:
				print("  OK: Nodo ", nodo, " tiene ", matriz_distancias[nodo].size(), " distancias")
	
	if not conexiones_invalidas.is_empty():
		push_error("NODOS CON PROBLEMAS: ", conexiones_invalidas)
		return
	
	print("\n✓ Validación completada - todas las conexiones son válidas\n")
	
	# Resetear variables globales
	mejor_distancia = INF
	mejor_ruta = []
	
	# --- INICIALIZACIÓN: Comenzar desde el nodo 0 (punto de salida) ---
	var ruta_inicial= [0]               # Ruta comienza en nodo 0
	var visitados= {0:true}             # Marcar nodo 0 como visitado
	
	# --- EJECUTAR ALGORITMO: Explorar todas las rutas posibles ---
	backtracking(0, ids_pedidos, visitados, ruta_inicial, 0, matriz_distancias)
	
	# Debug: Mostrar resultado
	print("\n" + "============================================================")
	if mejor_ruta.is_empty() or mejor_distancia == INF:
		push_error("❌ NO SE ENCONTRÓ RUTA VÁLIDA")
		print("Verifica que todos los nodos tengan conexiones entre sí")
		print("Recuerda: INF significa 'no conectado' - asegúrate de configurar distancias reales")
		print("Nodos solicitados: ", ids_pedidos)
	else:
		print("✓ Ruta encontrada: ", mejor_ruta)
		print("✓ Distancia total: ", mejor_distancia)
	print("============================================================" + "\n")
	
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

# --- PASO 5: ALGORITMO BACKTRACKING (PROBLEMA DEL VIAJANTE CON NODOS OBLIGATORIOS) ---
# Explora todas las rutas posibles pasando por nodos intermedios
# Los nodos en ids_pedidos son OBLIGATORIOS (tienen pedidos que entregar)
# Los demás nodos pueden usarse como "puentes" para conectar destinos no directamente conectados
# Ejemplo: Para ir A→F→D, puede usar B→C como puentes si A-B-C-F-D existe
# Parámetros:
#  - nodo_actual: nodo donde estamos actualmente
#  - ids_pedidos: lista de nodos OBLIGATORIOS que deben visitarse
#  - visitados: conjunto de nodos OBLIGATORIOS ya visitados
#  - ruta_actual: secuencia de nodos visitados hasta ahora
#  - distancia_acumulada: suma de distancias en la ruta actual
#  - matriz_distancias: grafo con todas las distancias
func backtracking(nodo_actual, ids_pedidos, visitados, ruta_actual, distancia_acumulada, matriz_distancias):
	# --- PODA 1: Si ya superamos la mejor distancia, no explorar esta rama ---
	if distancia_acumulada >= mejor_distancia:
		return
	
	# --- CONDICIÓN DE PARADA: Se han visitado TODOS los nodos OBLIGATORIOS ---
	# +1 porque incluye el nodo 0 de salida
	if len(visitados) == len(ids_pedidos) + 1:
		# Calcular distancia total cerrando la ruta (volviendo a nodo 0)
		var distancia_retorno = matriz_distancias[nodo_actual][0]
		
		# La distancia de retorno debe ser válida (no infinita)
		if distancia_retorno == INF:
			return  # No hay forma de volver al inicio, ruta inválida
		
		var distancia_total = distancia_acumulada + distancia_retorno
		# Si es mejor que la actual, guardarla
		if distancia_total < mejor_distancia:
			mejor_distancia = distancia_total
			mejor_ruta = ruta_actual.duplicate()
			mejor_ruta.append(0)  # Agregar retorno al nodo 0
		return
	
	# --- EXPLORACIÓN: Intentar ir a CUALQUIER nodo del grafo ---
	# No solo a los nodos obligatorios, sino a TODOS los nodos como posibles "puentes"
	for siguiente_nodo in range(matriz_distancias.size()):
		# Si este nodo aún no ha sido visitado EN LA RUTA ACTUAL
		if not ruta_actual.has(siguiente_nodo):
			# Obtener la distancia hacia el siguiente nodo
			var distancia_siguiente = matriz_distancias[nodo_actual][siguiente_nodo]
			
			# --- VALIDACIÓN: Saltar si no hay conexión directa ---
			if distancia_siguiente == INF:
				# Este camino no es posible, intentar con otro nodo
				continue
			
			# Agregar a la ruta actual
			ruta_actual.append(siguiente_nodo)
			
			# --- MARCAR COMO VISITADO solo si es un nodo OBLIGATORIO ---
			var era_obligatorio = false
			if ids_pedidos.has(siguiente_nodo):
				visitados[siguiente_nodo] = true
				era_obligatorio = true
				print("  → Visitando nodo OBLIGATORIO ", siguiente_nodo, " (tiene pedido)")
			else:
				print("  → Usando nodo PUENTE ", siguiente_nodo, " (para llegar a destino)")
			
			# Recursión: Explorar desde este nuevo nodo
			backtracking(
				siguiente_nodo,  # Nuevo nodo actual
				ids_pedidos, 
				visitados, 
				ruta_actual, 
				distancia_acumulada + distancia_siguiente,  # Acumular distancia
				matriz_distancias
			)
			
			# Backtrack: Deshacer cambios
			ruta_actual.pop_back()
			if era_obligatorio:
				visitados.erase(siguiente_nodo)
