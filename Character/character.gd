extends CharacterBody2D

enum MOVE_SET { NORMAL, BURBUJA }

const SPEED = 300.0
const JUMP_VELOCITY = -300.0
const JUMP_WALL_VELOCITY = Vector2(JUMP_VELOCITY,0)
const GRAVITY_WALL = Vector2(0,200)

const SPEED_BUBBLE = 100.0
const GRAVITY_BUBBLE = 100.0

var is_jumping:bool = false
var move_mode:MOVE_SET = MOVE_SET.NORMAL

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if move_mode == MOVE_SET.NORMAL:
		_move_on_ground(delta)
	else:
		_move_bubble(delta)
	
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		print(collision.get_collider().name)
		if (collision.get_collider() as Node).is_in_group("Bubbles"):
			set_move_mode(MOVE_SET.BURBUJA)
			print("bubble")
	
func set_move_mode(new_mode:MOVE_SET):
	move_mode = new_mode

func _move_bubble(delta:float):
	
	var directionX := Input.get_axis("ui_left", "ui_right")
	if directionX:
		velocity.x = directionX * SPEED_BUBBLE
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED_BUBBLE)
		
	var directionY := Input.get_axis("ui_up", "ui_down")
	if directionY:
		velocity.y = directionY * SPEED_BUBBLE
	else:
		velocity.y = move_toward(velocity.x, 0, SPEED_BUBBLE)
		
	velocity.y += GRAVITY_BUBBLE * delta
	
	if Input.is_action_just_pressed("ui_accept"):
		var exit = Vector2(0,0)
		if Input.is_action_pressed("ui_up"):
			exit = Vector2(0,1)
		if Input.is_action_pressed("ui_down"):
			exit = Vector2(0,-1)
		if Input.is_action_pressed("ui_right"):
			exit = Vector2(-1,0)
		if Input.is_action_pressed("ui_left"):
			exit = Vector2(1,0)
		
		is_jumping = true
		$JumpTimer.start()
		velocity = exit * JUMP_VELOCITY
		set_move_mode(MOVE_SET.NORMAL)
		

func _move_on_ground(delta:float) -> void:
	if not is_on_floor():
		if _is_on_wall():
			if velocity.y < 0: 
				velocity.y = 0
			velocity += GRAVITY_WALL * delta 
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
	
	
func _is_on_wall() -> bool:
	if is_jumping or is_on_floor(): 
		return false
		
	if $RayCastDer.is_colliding():
		return true
		
	if $RayCastIzq.is_colliding():
		return true
		
	return false
	


func _on_jump_timer_timeout() -> void:
	is_jumping = false
	
