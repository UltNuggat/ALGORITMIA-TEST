# GESTOR DE CONTENEDOR Y PEDIDOS (CONTAINER.GD)

# Maneja la interfaz de usuario para agregar/eliminar pedidos
# Implementa algoritmo de mochila para optimizar qué pedidos cargar
# Genera tickets con los pedidos seleccionados


extends Container

#  REFERENCIAS A OTRAS ESCENAS Y NODOS
const LINEA_PEDIDO = preload("uid://bj2tmp5vov1ia")

@onready var Lista_pedido =$"Main layout/ScrollContainer/VBoxContainer"
@onready var ticket_popup: AcceptDialog = $"Main layout/TicketPopUp"
@onready var camion: Node2D = %Camion

# Variables globales
var ids_incluidos = []   # IDs de nodos a visitar (resultado de mochila)
var ids_ticket= []       # IDs de pedidos en el ticket final


# Se ejecuta cuando el usuario presiona el botón "Agregar"
func _on_add_pressed() -> void:
	# Crear una nueva instancia de la fila de pedido
	var nuevo_pedido = LINEA_PEDIDO.instantiate()
	
	# Añadir la fila a la lista visual en la interfaz
	Lista_pedido.add_child(nuevo_pedido)
	
	# Configura los selectores de tipo y nodo ---
	var tipo_boton =  nuevo_pedido.get_node("Tipo")
	var nodo_boton =  nuevo_pedido.get_node("Nodo")
	
	# Agregar todas las opciones de tipos de pedido
	for tipo in Pedido.Tipo_pedido.keys():
		tipo_boton.add_item(tipo)
	
	# Agregar todas las opciones de nodos de destino
	for nodo in Pedido.Nodos_posibles.keys():
		nodo_boton.add_item(nodo)
	
	# Reordenar y actualizar los IDs de todos los pedidos
	_reordenar_ids()
	
	# Conectar el botón de eliminar para este pedido
	var delete_btn = nuevo_pedido.get_node("DeleteButton")
	delete_btn.pressed.connect(func(): _borra_pedido(nuevo_pedido))


# Se ejecuta cuando el usuario presiona "Eliminar" en un pedido
func _borra_pedido(nodo_pedido):
	# Remover el nodo de la escena
	Lista_pedido.remove_child(nodo_pedido)
	# Liberar la memoria del nodo
	nodo_pedido.queue_free()
	# Reordenar IDs de los pedidos restantes
	_reordenar_ids()

#Actualiza los IDs de todos los pedidos para mantener su orden
func _reordenar_ids():
	var hijos = Lista_pedido.get_children()
	for i in range(hijos.size()):
		var fila = hijos[i]
		fila.get_node("ID").text = "Pedido #" + str(i+1)

# Convierte la información de UI en pedidos
var todos_los_pedidos : Array[Pedido] = [] 
func _actualizar_datos_de_pedido():
	todos_los_pedidos.clear()
	
	# Iterar sobre cada fila de pedido en la UI
	for linea in Lista_pedido.get_children():
		# Extraer datos de cada campo de la UI
		var id_val = linea.get_node("ID").text.to_int()
		var tipo_val = linea.get_node("Tipo").selected
		var precio_val = linea.get_node("Price").value
		var peso_val = linea.get_node("Weight").value
		# Sumar 1 porque el nodo 0 es el punto almacen/mercadona
		var nodo_val = linea.get_node("Nodo").selected +1
		
		# Crear pedido con los datos recopilados
		var nuevo_pedido_objeto = Pedido.new(id_val,tipo_val,peso_val,precio_val,nodo_val)
		todos_los_pedidos.append(nuevo_pedido_objeto)
	
	# Debug
	for item in todos_los_pedidos:
		item.printer()

# Se ejecuta cuando el usuario presiona "Generar Ticket"
func _on_ticket_pressed() -> void:
	# Actualizar datos de todos los pedidos desde la UI
	_actualizar_datos_de_pedido()
	
	# Obtener la capacidad máxima del camión
	var capacidad_maxima = camion.espacio_total
	# Aplicar algoritmo de mochila para seleccionar pedidos óptimos
	seleccion_pedidos(todos_los_pedidos, capacidad_maxima)

	# Generar y mostrar el ticket
	print_ticket()

# Selecciona los pedidos que maximizan el beneficio sin exceder la capacidad
func seleccion_pedidos(pedidos, capacidad_maxima):
	ids_incluidos.clear()
	var n = len(pedidos)
	
	
	# tabla[i][j] = máximo beneficio usando primeros i pedidos con capacidad j
	var tabla = []
	for y in range (n + 1):
		var fila = []
		fila.resize(capacidad_maxima + 1)
		fila.fill(0)  # Inicializar con 0s
		tabla.append(fila)
	
	# Llenar la tabla de programación dinámica
	for i in range(1, n + 1):
		var peso_actual = pedidos[i - 1].peso
		var beneficio_actual = pedidos[i - 1].precio
		
		# Para cada capacidad posible
		for j in range(capacidad_maxima + 1):
			# Si el peso actual no cabe, ignorar este pedido
			if peso_actual > j:
				tabla[i][j] = tabla[i-1][j]
			else:
				# Tomar el máximo: incluir o no incluir este pedido
				tabla[i][j] = max(tabla[i-1][j], beneficio_actual + tabla[i-1][j - peso_actual])
	
	
	ids_incluidos = []
	ids_ticket= []
	var j = capacidad_maxima
	for i in range(n,0,-1):
		# Si el valor cambió, significa que se incluyó este pedido
		if tabla[i][j] != tabla[i-1][j]:
			ids_incluidos.append(pedidos[i-1].nodo)  # Agregar nodo de destino
			ids_ticket.append(pedidos[i-1].id)        # Agregar ID del pedido
			j -= pedidos[i-1].peso                    # Restar peso de capacidad
	ids_incluidos.reverse()  # Invertir para obtener orden correcto
	
	# Quitar ids duplicados
	var vistos= {}
	var ids_distintos = []
	for id in ids_incluidos:
		if not vistos.has(id):
			vistos[id] = true
			ids_distintos.append(id)
	ids_incluidos = ids_distintos

	# Debug
	print("Maximo es: "+ str(tabla[n][capacidad_maxima]) + " usando los pedidos: "+ str(ids_incluidos))
	for i in tabla:
		print(i)
	
	

# mostrar ticket por pantalla
func print_ticket():
	# Verificar si hay pedidos seleccionados
	if ids_ticket.is_empty():
		ticket_popup.dialog_text = "No hay pedidos en la lista."
	else:
		# Construir texto del ticket
		var texto_final = "RESUMEN DE PEDIDOS:\n"
		texto_final += "----------------------------\n"
		
		# Agregar cada pedido seleccionado al ticket
		for item in todos_los_pedidos:
			for ids in ids_ticket:
				if item.id == ids: 
					texto_final += item.generar_texto_ticket()
					
		ticket_popup.dialog_text = texto_final
	
	# Mostrar el popup del ticket en el centro de la pantalla
	ticket_popup.popup_centered()
