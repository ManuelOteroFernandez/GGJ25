extends Node2D

@onready var music_menu = load("res://Musica/2.Musica/Gatopompas_menu_loop.mp3")
@onready var music_game = load("res://Musica/2.Musica/Gatopompas_completo_loop.mp3")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameController.end_game_signal.connect(_on_end_game)
	GameController.init_game_signal.connect(_on_init_game)
	$CanvasLayer/fade_screen.to_white()
	$Music.play()

func _on_init_game():
	$Music.stream = music_game
	$Music.play()
	
func _on_end_game():
	$Music.stream = music_menu
	$Music.play()


func _on_win(body: Node2D) -> void:
	GameController.end_game()
