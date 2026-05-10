extends Container

# Preload the row scene we just created
const LINEA_PEDIDO = preload("uid://bj2tmp5vov1ia")

@onready var Lista_pedido =$"Main layout/ScrollContainer/VBoxContainer"
@onready var ticket_popup: AcceptDialog = $"Main layout/TicketPopUp"
@onready var camion: Node2D = %Camion

var ids_incluidos = []
var ids_ticket= []

func _on_add_pressed() -> void:
	# Crea instancia de pedido
	var nuevo_pedido = LINEA_PEDIDO.instantiate()
	
	# Añadelo a la lista
	Lista_pedido.add_child(nuevo_pedido)
	
	# conectar tipos y nodos posibles 
	var tipo_boton =  nuevo_pedido.get_node("Tipo")
	var nodo_boton =  nuevo_pedido.get_node("Nodo")
	
	for tipo in Pedido.Tipo_pedido.keys():
		tipo_boton.add_item(tipo)
	
	for nodo in Pedido.Nodos_posibles.keys():
		nodo_boton.add_item(nodo)
	
	# Ponle id
	_reordenar_ids()
	#var order_id = Lista_pedido.get_child_count()
	#nuevo_pedido.get_node("ID").text = "Order #" + str(order_id)
	
	# Conecta boton de borrar
	var delete_btn = nuevo_pedido.get_node("DeleteButton")
	delete_btn.pressed.connect(func(): _borra_pedido(nuevo_pedido))

func _borra_pedido(nodo_pedido):
	Lista_pedido.remove_child(nodo_pedido)
	nodo_pedido.queue_free()
	_reordenar_ids()

func _reordenar_ids():
	var hijos = Lista_pedido.get_children()
	for i in range(hijos.size()):
		var fila = hijos[i]
		fila.get_node("ID").text = "Pedido #" + str(i+1)



var todos_los_pedidos : Array[Pedido] = [] 
func _actualizar_datos_de_pedido():
	todos_los_pedidos.clear()
	
	
	for linea in Lista_pedido.get_children():
		var id_val = linea.get_node("ID").text.to_int()
		var tipo_val = linea.get_node("Tipo").selected
		var precio_val = linea.get_node("Price").value
		var peso_val = linea.get_node("Weight").value
		var nodo_val = linea.get_node("Nodo").selected +1 #mas uno prque el mercadona de salida tiene id de 0 como nodo
		
		var nuevo_pedido_objeto = Pedido.new(id_val,tipo_val,peso_val,precio_val,nodo_val)
		todos_los_pedidos.append(nuevo_pedido_objeto)
	
	for item in todos_los_pedidos:
		item.printer()

func _on_ticket_pressed() -> void:
	_actualizar_datos_de_pedido()
	
	var capacidad_maxima = camion.espacio_total
	seleccion_pedidos(todos_los_pedidos, capacidad_maxima)
	
func seleccion_pedidos(pedidos, capacidad_maxima):
	ids_incluidos.clear()
	var n = len(pedidos)
	
	var tabla = []
	for y in range (n + 1):
		var fila = []
		fila.resize(capacidad_maxima + 1)
		fila.fill(0)
		tabla.append(fila)
	
	for i in range(1, n + 1):
		var peso_actual = pedidos[i - 1].peso
		var beneficio_actual = pedidos[i - 1].precio
		
		for j in range(capacidad_maxima + 1):
			if peso_actual > j:
				tabla[i][j] = tabla[i-1][j]
			else:
				tabla[i][j] = max(tabla[i-1][j], beneficio_actual + tabla[i-1][j - peso_actual])
	
	ids_incluidos = []
	ids_ticket= []
	var j = capacidad_maxima
	for i in range(n,0,-1):
		if tabla[i][j] != tabla[i-1][j]:
			ids_incluidos.append(pedidos[i-1].nodo)
			ids_ticket.append(pedidos[i-1].id)
			j -= pedidos[i-1].peso
	ids_incluidos.reverse()
	
	var vistos= {}
	var ids_distintos = []
	for id in ids_incluidos:
		if not vistos.has(id):
			vistos[id] = true
			ids_distintos.append(id)
	ids_incluidos = ids_distintos


	print("Maximo es: "+ str(tabla[n][capacidad_maxima]) + " usando los pedidos: "+ str(ids_incluidos))
	for i in tabla:
		print(i)
	
	print_ticket()

func print_ticket():
	if ids_ticket.is_empty():
		ticket_popup.dialog_text = "No hay pedidos en la lista."
	else:
		var texto_final = "RESUMEN DE PEDIDOS:\n"
		texto_final += "----------------------------\n"
		
		for item in todos_los_pedidos:
			for ids in ids_ticket:
				if item.id == ids: 
					texto_final += item.generar_texto_ticket()
					
		ticket_popup.dialog_text = texto_final
	
	# Esto hace que aparezca en el centro de la pantalla
	ticket_popup.popup_centered()
