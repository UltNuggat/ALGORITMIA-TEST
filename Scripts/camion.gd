# CONTROL DEL CAMIÓN (CAMION.GD)

# Maneja el movimiento del camión, animaciones y viajes por ruta
# Controla los espacios para diferentes tipos de pedidos


extends Node2D

#  REFERENCIAS A OTROS NODOS
@onready var ciudad: Node2D = %Ciudad

# CAPACIDADES DEL CAMIÓN: Espacio disponible para cada tipo de pedido 
@export var espacio_normal: float= 10     # Espacio para pedidos normales
@export var espacio_fragil: float= 0      # Espacio para pedidos frágiles
@export var espacio_frio: float= 0        # Espacio para pedidos refrigerados
@export var espacio_caliente: float= 0    # Espacio para pedidos calientes

# Capacidad total: Suma de todos los espacios disponibles 
@onready var espacio_total = espacio_normal+ espacio_frio + espacio_fragil + espacio_caliente

# Parámetros variables
@export var velocidad: float = 250.0      # Velocidad de movimiento del camión (píxeles/segundo)
@export var squash_intensity: float = 0.15 # Intensidad de la animación de "rebote"
@export var squash_speed: float = 0.1     # Duración de cada frame de animación

# Tween para animacion
var squash_tween: Tween 


# Funcion para que se mueva
func viajar(puntos: Array):
	# Validar que hay puntos para visitar
	if puntos.is_empty():
		return
	
	# crear tween principal: movimiento
	var main_tween = create_tween()
	
	# Si hay una animación de squash activa, destruirla ---
	if squash_tween:
		squash_tween.kill() 
	
	# Animación de squash infinita durante el movimiento ---
	squash_tween = create_tween().set_loops()
	# Primera fase: compresión vertical, expansión horizontal
	squash_tween.tween_property(self, "scale", Vector2(1.0 + squash_intensity, 1.0 - squash_intensity), squash_speed)
	# Segunda fase: expansión vertical, compresión horizontal
	squash_tween.tween_property(self, "scale", Vector2(1.0 - (squash_intensity/2), 1.0 + squash_intensity), squash_speed)
	# Tercera fase: volver a escala normal
	squash_tween.tween_property(self, "scale", Vector2(1.0, 1.0), squash_speed)

	# recorrer ruta
	for i in range(puntos.size()):
		var punto_destino = puntos[i]
		# Calcular distancia desde posición actual o desde punto anterior
		var d = global_position.distance_to(punto_destino)
		if i > 0:
			d = puntos[i-1].distance_to(punto_destino)
		
		# Calcular tiempo de viaje basado en distancia y velocidad
		var tiempo = d / velocidad
		
		# Animar movimiento a este punto
		main_tween.tween_property(self, "global_position", punto_destino, tiempo)
		
		# Pausar animación de squash cuando lleguemos al punto
		main_tween.tween_callback(func(): squash_tween.pause())
		
		# Esperar un poco en cada punto (0.5 segundos)
		main_tween.tween_interval(0.5)
		
		# Reanudar animación de squash si no es el último punto
		if i < puntos.size() - 1:
			main_tween.tween_callback(func(): squash_tween.play())

	#  Ejecutar función cuando termine el viaje
	main_tween.finished.connect(_on_ruta_terminada)

#  Se ejecuta cuando termina el viaje 
func _on_ruta_terminada():
	# Limpiar animación de squash
	if squash_tween:
		squash_tween.kill()
		# Asegurar que el camión quede en escala normal (1, 1)
		var final_snap = create_tween().tween_property(self, "scale", Vector2(1, 1), 0 )
