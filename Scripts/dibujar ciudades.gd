# RENDERIZACIÓN VISUAL DE NODOS (DIBUJAR CIUDADES.GD)

# Dibuja círculos visuales para cada nodo y sus etiquetas en la pantalla
# Se ejecuta automáticamente para renderizar llas ciudades


extends Node2D

#  REFERENCIAS A OTROS NODOS
@onready var nodos: Node2D = $"."


# Se llama automáticamente cuando Godot necesita redibujar la escena
func _draw() -> void:
	# Obtener tipo de fuente para el texto
	var default_font = ThemeDB.fallback_font

	
	# Dibujar cada nodo
	for nodo in nodos.get_children():
		# Dibujar círculo naranja en la posición del nodo (radio 20)
		draw_circle(nodo.position, 20, Color.ORANGE)
		# Dibujar el nombre del nodo como texto en el círculo
		draw_string(default_font, nodo.position + Vector2(-7,5), str(nodo.name))
