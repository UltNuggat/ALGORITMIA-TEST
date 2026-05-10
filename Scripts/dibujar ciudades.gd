extends Node2D
@onready var nodos: Node2D = $"."


func _draw() -> void:
	var default_font = ThemeDB.fallback_font
	var defoult_font_size = ThemeDB.fallback_font_size
	for nodo in nodos.get_children():
		draw_circle(nodo.position, 20, Color.ORANGE)
		draw_string(default_font,nodo.position + Vector2(-7,5),str(nodo.name))
