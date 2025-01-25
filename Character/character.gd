class_name Player extends CharacterBody2D

enum MOVE_SET { NORMAL, BURBUJA }
enum ANIM_STATE_SET { JUMP, IDLE, RUN , FALL, WALL, JUMP_WALL }

const SPEED = 300.0
const JUMP_VELOCITY = -600.0
const JUMP_WALL_VELOCITY = Vector2(JUMP_VELOCITY,0)
const GRAVITY_WALL = Vector2(0,200)

const SPEED_BUBBLE = 200.0
const GRAVITY_BUBBLE = 100.0

var is_jumping:bool = false
var move_mode:MOVE_SET = MOVE_SET.NORMAL
var current_dir = 1
var anim_state = ANIM_STATE_SET.IDLE

func _process(_delta: float) -> void:
	if anim_state == ANIM_STATE_SET.RUN:
		if move_mode == MOVE_SET.BURBUJA:
			$AnimatedSprite2D.animation = "moveBubbleL" if current_dir < 0 else "moveBubbleR"
		else:
			$AnimatedSprite2D.animation = "runL" if current_dir < 0 else "runR"
	elif anim_state == ANIM_STATE_SET.JUMP and $AnimatedSprite2D.animation not in ["jumpL","jumpR"]:
		$AnimatedSprite2D.animation = "jumpL" if current_dir < 0 else "jumpR"
		$AnimatedSprite2D.play()
	elif anim_state == ANIM_STATE_SET.IDLE:
		
		if move_mode == MOVE_SET.BURBUJA:
			$AnimatedSprite2D.animation = "idleBubbleL" if current_dir < 0 else "idleBubbleR"
		else:
			$AnimatedSprite2D.animation = "idleL" if current_dir < 0 else "idleR"
	elif anim_state == ANIM_STATE_SET.WALL:
		$AnimatedSprite2D.animation = "slideL" if current_dir < 0 else "slideR"
	elif anim_state == ANIM_STATE_SET.FALL:
		$AnimatedSprite2D.animation = "fallL" if current_dir < 0 else "fallR"
		
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if move_mode == MOVE_SET.NORMAL:
		_move_on_ground(delta)
	else:
		_move_bubble(delta)
	
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		#print(collision.get_collider().name)
		var node_collision = (collision.get_collider() as Node)
		if node_collision.is_in_group("Bubbles"):
			set_move_mode(MOVE_SET.BURBUJA)
	
		if node_collision.is_in_group("Muro"):
			set_move_mode(MOVE_SET.NORMAL)
	
func set_move_mode(new_mode:MOVE_SET):
	move_mode = new_mode
	if move_mode == MOVE_SET.BURBUJA:
		set_collision_layer_value(3,true)
		set_collision_mask_value(3,true)
		$BubbleTemplate.visible = true
	else:
		set_collision_layer_value(3,false)
		set_collision_mask_value(3,false)
		$BubbleTemplate.visible = false

func _move_bubble(delta:float):
	
	anim_state = ANIM_STATE_SET.IDLE
	var directionX := Input.get_axis("ui_left", "ui_right")
	if directionX:
		current_dir = directionX
		velocity.x = directionX * SPEED_BUBBLE
		anim_state = ANIM_STATE_SET.RUN
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED_BUBBLE)
		
	if Input.is_action_pressed("ui_down"):
		velocity.y += SPEED_BUBBLE * 10 * delta
		
	var g = get_gravity()
	velocity.y += GRAVITY_BUBBLE * delta if g.y > 0 else g.y * delta
	
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
		
		if exit != Vector2(0,0):
			anim_state = ANIM_STATE_SET.FALL
			$JumpTimer.start()
			velocity = exit * JUMP_VELOCITY
			set_move_mode(MOVE_SET.NORMAL)
		

func _move_on_ground(delta:float) -> void:
	if not is_on_floor():
		if _is_on_wall():
			if velocity.y < 0: 
				velocity.y = 0
			velocity += GRAVITY_WALL * delta 
			anim_state = ANIM_STATE_SET.WALL
		else:
			velocity += get_gravity() * delta

	
	if anim_state != ANIM_STATE_SET.JUMP_WALL:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			current_dir = direction
			velocity.x = direction * SPEED
			if is_on_floor():
				anim_state = ANIM_STATE_SET.RUN
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		anim_state = ANIM_STATE_SET.JUMP

	if Input.is_action_just_pressed("ui_accept") and _is_on_wall():
		anim_state = ANIM_STATE_SET.JUMP_WALL
			
		$JumpTimer.start()
		velocity.y = JUMP_WALL_VELOCITY.y
		velocity.x = JUMP_WALL_VELOCITY.x if $RayCastDer.is_colliding() else -JUMP_WALL_VELOCITY.x
	
	if velocity.y > 0 and anim_state not in [ANIM_STATE_SET.JUMP_WALL, ANIM_STATE_SET.WALL]:
		anim_state = ANIM_STATE_SET.FALL
	
	if velocity == Vector2(0,0):
		anim_state = ANIM_STATE_SET.IDLE
		
	
func _is_on_wall() -> bool:
	if is_on_floor(): 
		return false
		
	if $RayCastDer.is_colliding():
		return true
		
	if $RayCastIzq.is_colliding():
		return true
		
	return false
	
func dead():
	position = GameController.last_checkpoint_position

func _on_jump_timer_timeout() -> void:
	if is_on_floor():
		anim_state = ANIM_STATE_SET.RUN
	else:
		anim_state = ANIM_STATE_SET.FALL
