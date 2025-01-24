extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -300.0
const JUMP_WALL_VELOCITY = Vector2(JUMP_VELOCITY,JUMP_VELOCITY/1.5)

@export var gravity_wall = Vector2(0,200)

var is_jumping:bool = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		if _is_on_wall():
			if velocity.y < 0: 
				velocity.y = 0  
			velocity += gravity_wall * delta 
		else:
			velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if not is_jumping:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	if Input.is_action_just_pressed("ui_accept") and _is_on_wall():
		is_jumping = true
		$JumpTimer.start()
		velocity.y = JUMP_WALL_VELOCITY.y
		velocity.x = JUMP_WALL_VELOCITY.x if $RayCastDer.is_colliding() else -JUMP_WALL_VELOCITY.x
		
	move_and_slide()
	
func _is_on_wall() -> bool:
	if is_jumping: 
		return false
		
	if $RayCastDer.is_colliding():
		return true
		
	if $RayCastIzq.is_colliding():
		return true
		
	return false
	


func _on_jump_timer_timeout() -> void:
	is_jumping = false
