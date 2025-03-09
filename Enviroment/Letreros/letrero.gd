extends Node2D

@export var contenido: PackedScene

var cartel : Cartel

func _ready() -> void:
	if contenido and $InitialPointCartel.get_child_count() == 0:
		var cont_node = contenido.instantiate()
		if cont_node is Cartel:
			cartel = cont_node
			$InitialPointCartel.add_child(cartel)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if cartel and body.is_in_group("Player"):
		cartel.show_cartel()
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	if cartel and body.is_in_group("Player"):
		cartel.hide_cartel()
