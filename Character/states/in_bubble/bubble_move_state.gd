class_name BubbleMoveState
extends BaseState


const FORCE_BUBBLE = 10


func on_start(_data: Dictionary = {}) -> void:
	character.anim_state = Player.ANIM_STATE_SET.BUBBLE_MOVE

func on_end() -> void:
	pass

func on_input(event: InputEvent) -> void:
	var bubble = character.get_bubble()
	if not bubble: return
	
	if event.is_action_pressed("jump"):
		character.state_machine.change_state(StateMachine.State.BUBBLE_JUMP)
		return

func on_physics_process(_delta: float) -> void:
	var bubble = character.get_bubble()
	if not bubble: return
	
	
	if bubble.bubbleT.type == GameController.bubbleType.lineal: return
	
	var x_axis = Input.get_axis("move_left", "move_right")
	if x_axis != 0 and bubble.external_forces.x == 0:
		bubble.add_external_force(Vector2(x_axis * FORCE_BUBBLE,0))
	elif x_axis == 0 and bubble.external_forces.x != 0:
		bubble.add_external_force(Vector2(bubble.external_forces.x * -1,0))
	
	if x_axis != 0:
		character.current_dir = x_axis
	
	if bubble.bubbleT.type == GameController.bubbleType.floating: return
			
	var y_axis = Input.get_axis("move_up", "move_down")
	if y_axis != 0 and bubble.external_forces.y == 0:
		bubble.add_external_force(Vector2(0,y_axis * FORCE_BUBBLE))
	elif y_axis == 0 and bubble.external_forces.y != 0:
		bubble.add_external_force(Vector2(0, bubble.external_forces.y * -1))
		
	if x_axis == 0 and y_axis == 0:
		character.state_machine.change_state(StateMachine.State.BUBBLE_IDLE)

func on_process(_delta: float) -> void:
	pass
