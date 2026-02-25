class_name SliceJumpState
extends BaseState

const JUMP_DECELERATION = 100
const JUMP_SLICE_VELOCITY = Vector2(Player.JUMP_VELOCITY,0)
const JUMP_MIN_DISTANCE = 256

var global_position_at_start: Vector2

func on_start(_data: Dictionary = {}) -> void:
	
	character.anim_state = Player.ANIM_STATE_SET.JUMP_SLICE

	global_position_at_start = character.global_position

	character.current_dir *= -1
	character.velocity.y = JUMP_SLICE_VELOCITY.y
	character.velocity.x = JUMP_SLICE_VELOCITY.x if character.ray_der.is_colliding() else -JUMP_SLICE_VELOCITY.x


func on_end() -> void:
	pass


func on_input(_event: InputEvent) -> void:
	pass


func on_physics_process(delta: float) -> void:
	var distance := global_position_at_start.distance_to(character.global_position)
	if distance >= JUMP_MIN_DISTANCE:
		character.state_machine.change_state(StateMachine.State.FALL)
		return

	if character.is_on_floor():
		character.state_machine.change_state(
			StateMachine.State.IDLE if character.velocity.x == 0 else StateMachine.State.RUN
		)
		return
	
	if distance >= 64 and character.check_is_on_wall():
		character.state_machine.change_state(StateMachine.State.SLICE)
		return

	move(delta)


func move(delta: float) -> void:
	character.apply_gravity(delta)
	character.velocity.x = move_toward(character.velocity.x, 0, JUMP_DECELERATION * delta)

	character.move_and_slide()

	var bubble_collided = character.check_collision_with_bubble()
	if bubble_collided:
		character.set_move_bubble(bubble_collided)


func on_process(_delta: float) -> void:
	pass
