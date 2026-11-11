class_name JumpState
extends BaseState

func on_start(_data: Dictionary = {}) -> void:
	character.set_move_ground()
	
	character.anim_state = Player.ANIM_STATE_SET.JUMP
	
	character.velocity.y = Player.JUMP_VELOCITY
	character.rotation = 0

func on_end() -> void:
	pass

func on_input(_event: InputEvent) -> void:
	pass

func on_physics_process(delta: float) -> void:	

	if character.velocity.y == 0 and character.is_on_floor():
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
			character.state_machine.change_state(StateMachine.State.RUN)	
			
		else:
			character.state_machine.change_state(StateMachine.State.IDLE)

		return	
	
	if character.velocity.y >= 0 and not character.is_on_floor():
		character.state_machine.change_state(StateMachine.State.FALL)
		return
	
	if character.check_is_on_wall():
		character.state_machine.change_state(StateMachine.State.SLICE)
		return
	
	move(delta)

func move(delta: float) -> void:
	character.apply_move_horizontal(delta)

	character.apply_gravity(delta)
	
	character.move_and_slide()

	var bubble_collided = character.check_collision_with_bubble()
	if bubble_collided:
		character.set_move_bubble(bubble_collided)

func on_process(_delta: float) -> void:
	pass
