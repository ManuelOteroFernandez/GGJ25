class_name SliceState
extends BaseState

enum SLICE_MODE {
	FAST,
	SLOW
}

const MAX_VELOCITY = 200

var slice_gravity:Vector2 
var current_slice_mode:SLICE_MODE

func on_start(_data: Dictionary = {}) -> void:
	
	change_slice_mode(SLICE_MODE.SLOW)

	character.anim_state = Player.ANIM_STATE_SET.SLICE
	character.velocity = Vector2.ZERO
	
	character.collision_shape.shape = character.shape_slide
	character.collision_shape.rotation_degrees = 0
	character.collision_shape.position = Vector2(-64 if character.current_dir < 0 else 64,-47)


func on_end() -> void:
	
	character.collision_shape.shape = character.shape_cat
	character.collision_shape.rotation_degrees = 90
	character.collision_shape.position = Vector2.ZERO


func on_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		character.state_machine.change_state(StateMachine.State.SLICE_JUMP)
	

func on_physics_process(delta: float) -> void:

	if character.is_on_floor():
		character.state_machine.change_state(StateMachine.State.IDLE)
	
	if not character.check_is_on_wall():
		character.state_machine.change_state(StateMachine.State.FALL)

	var move_dir = "move_right" if character.current_dir > 0 else "move_left"
	if Input.is_action_pressed(move_dir):
		change_slice_mode(SLICE_MODE.SLOW)
	else:
		change_slice_mode(SLICE_MODE.FAST)

	move(delta)


func move(delta: float) -> void:
	character.apply_move_horizontal(delta)
	
	if character.velocity.y >= MAX_VELOCITY and current_slice_mode == SLICE_MODE.SLOW:
		character.velocity.y = MAX_VELOCITY
	else:
		character.velocity += slice_gravity * delta
	
	character.move_and_slide()

	var bubble_collided = character.check_collision_with_bubble()
	if bubble_collided:
		character.set_move_bubble(bubble_collided)


func change_slice_mode(mode: SLICE_MODE) -> void:
	current_slice_mode = mode
	if mode == SLICE_MODE.FAST:
		slice_gravity = (character.get_gravity()  * Player.WEIGHT) / 1.3
	elif mode == SLICE_MODE.SLOW:
		slice_gravity = (character.get_gravity()  * Player.WEIGHT) / 4


func on_process(_delta: float) -> void:
	pass
