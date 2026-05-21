class_name IdleState
extends BaseState

func on_start(_data: Dictionary = {}) -> void:
	character.set_move_ground()

	character.anim_state = character.ANIM_STATE_SET.IDLE
	
	character.velocity = Vector2.ZERO
	character.rotate_with_surface(true)

	var dist_to_floor = character.calculate_floor_distance()
	if dist_to_floor > 1 and dist_to_floor != INF:
		character.global_position += Vector2(0, dist_to_floor).rotated(character.rotation)

func on_end() -> void:
	pass

func on_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left") or event.is_action_pressed("move_right") or \
	(event.is_action_released("move_left") and Input.is_action_pressed("move_right")) or \
	(event.is_action_released("move_right") and Input.is_action_pressed("move_left")):
		character.state_machine.change_state(StateMachine.State.RUN)

	if event.is_action_pressed("jump"):
		character.state_machine.change_state(StateMachine.State.JUMP)

func on_physics_process(delta: float) -> void:	
	
	if character.velocity.y > 0 and not character.is_near_floor():
		character.state_machine.change_state(StateMachine.State.FALL)
		return

	character.apply_gravity(delta)

	character.move_and_slide()

	var bubble_collided = character.check_collision_with_bubble()
	if bubble_collided:
		character.set_move_bubble(bubble_collided)

		
func on_process(_delta: float) -> void:
	pass
