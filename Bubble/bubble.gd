class_name Bubble
extends RigidBody2D

signal  pop_signal

@export var direction : Vector2 = Vector2(0,0)

@onready var sound_explota = load("res://bubble/sfx/Pompa explota.mp3")
@onready var sound_union = load("res://bubble/sfx/Fusion pompas.mp3")

@onready var audio: AudioStreamPlayer2D = $Audio

var animated_sprite: AnimatedSprite2D
var line_sprite: AnimatedSprite2D

var bubbleT: BubleTypeRes

var endurance: float = 0

var external_forces := Vector2.ZERO

var _spawning: bool = true

func add_external_force(force: Vector2):
	external_forces += force

func _ready() -> void:
	get_tree().create_timer(0.5).timeout.connect(func(): _spawning = false)


func _enter_tree() -> void:
	global_rotation = 0
	apply_central_force(direction)


func with_data(dir, type: BubleTypeRes):
	direction = dir
	bubbleT = type
	gravity_scale = type.gravity
	animated_sprite = $AnimatedSprite2D
	line_sprite = $LineSprite
	_change_endurance(type.endurance)
	

func pop() -> void:
	freeze = true
	set_collision_layer_value(1,false)
	set_collision_layer_value(3,false)
	set_collision_mask_value(1,false)
	set_collision_mask_value(3,false)
	
	pop_signal.emit()

	audio.stream = sound_explota
	audio.play()
	line_sprite.play("explotion")
	animated_sprite.play("explotion")
	await audio.finished

	queue_free()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Ground"):
		if _spawning:
			return
		if  endurance > 1:
			_change_endurance(-1)
			_play_hit_and_back()
		else:
			call_deferred("pop")
			
	elif body.is_in_group("Bubbles") and not body.is_in_group("Player"):
		_change_endurance(1)
		_play_hit_and_back()

		audio.stream = sound_union
		audio.play()

		apply_force(body.linear_velocity * get_process_delta_time())

		body.free()


func _change_endurance(delta:int):
	endurance = endurance + delta
	if endurance > bubbleT.endurance:
		endurance = bubbleT.endurance
	
	var color_index = ceili(bubbleT.color_array.size() * endurance/bubbleT.endurance) - 1
	animated_sprite.modulate = bubbleT.color_array[color_index]
	

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.linear_velocity += external_forces


func _play_hit_and_back():
	line_sprite.play("hit")
	animated_sprite.play("hit")
	print("%s hit" % self.name)
	if not animated_sprite.animation_finished.is_connected(_play_default):
		animated_sprite.animation_finished.connect(
			_play_default,
			ConnectFlags.CONNECT_ONE_SHOT
		)
	
	
func _play_default():
	print("%s default" % self.name)
	line_sprite.play("default")
	animated_sprite.play("default")
	
	
