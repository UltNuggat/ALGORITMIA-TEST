extends Node2D
@onready var ciudad: Node2D = %Ciudad

@export var espacio_normal: float= 5
@export var espacio_fragil: float= 0
@export var espacio_frio: float= 0
@export var espacio_caliente: float= 0

@onready var espacio_total = espacio_normal+ espacio_frio + espacio_fragil + espacio_caliente


@export var velocidad: float = 250.0 
@export var squash_intensity: float = 0.15 
@export var squash_speed: float = 0.1 

var squash_tween: Tween 

func viajar(puntos: Array):
	if puntos.is_empty():
		return
		
	
	var main_tween = create_tween()
	
	
	if squash_tween:
		squash_tween.kill() 
	
	squash_tween = create_tween().set_loops()
	squash_tween.tween_property(self, "scale", Vector2(1.0 + squash_intensity, 1.0 - squash_intensity), squash_speed)
	squash_tween.tween_property(self, "scale", Vector2(1.0 - (squash_intensity/2), 1.0 + squash_intensity), squash_speed)
	squash_tween.tween_property(self, "scale", Vector2(1.0, 1.0), squash_speed)

	# 3. Build the journey
	for i in range(puntos.size()):
		var punto_destino = puntos[i]
		var d = global_position.distance_to(punto_destino)
		if i > 0:
			d = puntos[i-1].distance_to(punto_destino)
			
		var tiempo = d / velocidad
		
		
		main_tween.tween_property(self, "global_position", punto_destino, tiempo)
		
		
		main_tween.tween_callback(func(): squash_tween.pause())
		
		
		main_tween.tween_interval(0.5)
		
		
		if i < puntos.size() - 1:
			main_tween.tween_callback(func(): squash_tween.play())

	
	main_tween.finished.connect(_on_ruta_terminada)

func _on_ruta_terminada():
	if squash_tween:
		squash_tween.kill()
		var final_snap = create_tween().tween_property(self, "scale", Vector2(1, 1), 0 )
