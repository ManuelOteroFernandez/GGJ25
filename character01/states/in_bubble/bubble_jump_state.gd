class_name BubbleJumpState
extends BaseState

const JUMP_DECELERATION = 100
const JUMP_VELOCITY = -2200.0
const JUMP_MIN_DISTANCE = 256

var global_position_at_start: Vector2

func on_start(_data: Dictionary = {}) -> void:
	character.anim_state = Player.ANIM_STATE_SET.BUBBLE_JUMP

	var bubble = character.get_bubble()
	if not bubble: return
	
	var exit = Vector2(0,0)
	if Input.is_action_pressed("move_up"):
		exit = Vector2(0, 1)
	if Input.is_action_pressed("move_down"):
		exit = Vector2(0, -1)
	if Input.is_action_pressed("move_left"):
		if exit == Vector2.ZERO:
			exit = Vector2(1, 0.2)
		else: 
			exit.x = 1
	if Input.is_action_pressed("move_right"):
		if exit == Vector2.ZERO:
			exit = Vector2(-1, 0.2)
		else: 
			exit.x = -1
			
	if exit == Vector2.ZERO:
		exit = Vector2(0,1)
		
	character.set_move_ground()
	
	bubble.pop_signal.disconnect(character.bubble_pop)
	bubble.pop()
	
	character.velocity = exit * JUMP_VELOCITY

	global_position_at_start = character.global_position

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
	
	var distance := global_position_at_start.distance_to(character.global_position)
	if distance >= JUMP_MIN_DISTANCE:
		character.state_machine.change_state(StateMachine.State.FALL)
		return
	
	if character.check_is_on_wall():
		character.state_machine.change_state(StateMachine.State.SLICE)
		return
		
	character.apply_gravity(delta)
	character.velocity.x = move_toward(character.velocity.x, 0, JUMP_DECELERATION * delta)
	
	character.move_and_slide()
	
	var bubble_collided = character.check_collision_with_bubble()
	if bubble_collided:
		character.set_move_bubble(bubble_collided)
	
	
func on_process(_delta: float) -> void:
	pass
