class_name BubbleIdleState
extends BaseState

func on_start(_data: Dictionary = {}) -> void:
	character.anim_state = Player.ANIM_STATE_SET.BUBBLE_IDLE

func on_end() -> void:
	pass

func on_input(event: InputEvent) -> void:
	var bubble = character.get_bubble()
	if not bubble: return
	
	if event.is_action_pressed("jump"):
		character.state_machine.change_state(StateMachine.State.BUBBLE_JUMP)
		return
	
	# Detectar input de movimiento y cambiar a bubble_move
	if bubble.bubbleT.type != GameController.bubbleType.lineal:
		if event.is_action_pressed("move_left") or event.is_action_pressed("move_right"):
			character.state_machine.change_state(StateMachine.State.BUBBLE_MOVE)
			return
	
	if bubble.bubbleT.type == GameController.bubbleType.free:
		if event.is_action_pressed("move_up") or event.is_action_pressed("move_down"):
			character.state_machine.change_state(StateMachine.State.BUBBLE_MOVE)
			return

func on_physics_process(_delta: float) -> void:
	var bubble = character.get_bubble()
	if not bubble: return
	
	if bubble.external_forces.x != 0:
		bubble.add_external_force(Vector2(bubble.external_forces.x * -1,0))
	
	if bubble.external_forces.y != 0:
		bubble.add_external_force(Vector2(0,bubble.external_forces.y * -1))
		

func on_process(_delta: float) -> void:
	pass
