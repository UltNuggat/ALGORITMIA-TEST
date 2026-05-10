# ============================================================================
# RENDERIZACIÓN VISUAL DE NODOS (DIBUJAR CIUDADES.GD)
# ============================================================================
# Dibuja círculos visuales para cada nodo y sus etiquetas en la pantalla
# Se ejecuta automáticamente para renderizar los elementos gráficos
# ============================================================================

extends Node2D

# --- REFERENCIAS: Referencia a los nodos de la ciudad ---
@onready var nodos: Node2D = $"."

# --- RENDERIZACIÓN: Dibuja los nodos y sus etiquetas ---
# Se llama automáticamente cuando Godot necesita redibujar la escena
func _draw() -> void:
	# Obtener fuente por defecto del tema
	var default_font = ThemeDB.fallback_font
	var default_font_size = ThemeDB.fallback_font_size
	
	# Iterar sobre cada nodo hijo y dibujarlo
	for nodo in nodos.get_children():
		# Dibujar círculo naranja en la posición del nodo (radio 20)
		draw_circle(nodo.position, 20, Color.ORANGE)
		# Dibujar el nombre del nodo como texto en el círculo
		draw_string(default_font, nodo.position + Vector2(-7,5), str(nodo.name))
