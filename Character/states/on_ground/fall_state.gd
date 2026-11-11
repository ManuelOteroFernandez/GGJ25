class_name FallState
extends BaseState

func on_start(_data: Dictionary = {}) -> void:
	character.set_move_ground()

	character.anim_state = Player.ANIM_STATE_SET.FALL


func on_physics_process(delta: float) -> void:
	if character.is_on_floor():
		character.state_machine.change_state(
			StateMachine.State.IDLE if character.velocity.x == 0 else StateMachine.State.RUN
		)
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


func on_end() -> void:
	pass


func on_input(_event: InputEvent) -> void:
	pass


func on_process(_delta: float) -> void:
	pass
