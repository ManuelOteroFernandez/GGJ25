class_name Player extends CharacterBody2D

signal on_dead_signal

enum MOVE_SET { NORMAL, BURBUJA }
enum ANIM_STATE_SET { JUMP, IDLE, RUN , FALL, WALL, JUMP_WALL }

const SPEED = 500.0
const JUMP_VELOCITY = -650.0
# Constante de salto dende a burbulla
const BUBBLE_JUMP_VELOCITY = -900.0
const JUMP_WALL_VELOCITY = Vector2(JUMP_VELOCITY,0)
const GRAVITY_WALL = Vector2(0,200)

const FORCE_BUBBLE = 0.5

@onready var shape_cat: CapsuleShape2D = load("res://Character/shapeCat.tres")
@onready var shape_bubble: CircleShape2D = load("res://Character/shapeBubble.tres")

@onready var audio_comp = $AudioStreamPlayer2D
@onready var first_parent = get_parent()

var _last_bubble_collided_id:int

var is_jumping:bool = false
var move_mode:MOVE_SET = MOVE_SET.NORMAL
var current_dir = 1
var anim_state = ANIM_STATE_SET.IDLE


func _input(event: InputEvent) -> void:
	if move_mode == MOVE_SET.BURBUJA:
		var bubble = get_parent() as Bubble
		if not bubble: return
		
		if event.is_action_pressed("ui_accept"):
			var exit = Vector2(0,0)
			if Input.is_action_pressed("ui_up"):
				exit.y = 1
			if Input.is_action_pressed("ui_down"):
				exit.y = -1
			if Input.is_action_pressed("ui_left"):
				exit.x = 1
			if Input.is_action_pressed("ui_right"):
				exit.x = -1
			if exit == Vector2(0,0):
				exit = Vector2(0,1)
			
			anim_state = ANIM_STATE_SET.JUMP
			bubble.pop()
			set_move_mode(MOVE_SET.NORMAL)
			velocity = exit * BUBBLE_JUMP_VELOCITY
		
		if bubble.bubbleT.type == GameController.bubbleType.lineal: return
		
		if event.is_action_pressed("ui_up") or event.is_action_released("ui_down"):
			bubble.add_constant_central_force(Vector2.UP * FORCE_BUBBLE)
			
		if event.is_action_pressed("ui_down") or event.is_action_released("ui_up"):
			bubble.add_constant_central_force(Vector2.DOWN * FORCE_BUBBLE)
		
		if bubble.bubbleT.type == GameController.bubbleType.floating: return
		
		if event.is_action_pressed("ui_right") or event.is_action_released("ui_left"):
			bubble.add_constant_central_force(Vector2.RIGHT * FORCE_BUBBLE)
			
		if event.is_action_pressed("ui_left") or event.is_action_released("ui_right"):
			bubble.add_constant_central_force(Vector2.LEFT * FORCE_BUBBLE)
	
func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		current_dir = direction
		if move_mode == MOVE_SET.BURBUJA:
			anim_state = ANIM_STATE_SET.RUN
	else:
		anim_state = ANIM_STATE_SET.IDLE
		
	if move_mode != MOVE_SET.NORMAL: return 
	
		
	_move_on_ground(delta,direction)
	
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if not collision: continue
		
		var node_collision = (collision.get_collider() as Node)
		if node_collision.is_in_group("Bubbles"):
			
			var node_id = node_collision.get_instance_id()
			if node_id == _last_bubble_collided_id:
				continue
				
			_last_bubble_collided_id = node_id
			
			var bubble = node_collision as Bubble
			set_move_mode(MOVE_SET.BURBUJA,bubble)
	
func set_move_mode(new_mode:MOVE_SET, bubble: Bubble = null):
	move_mode = new_mode
	if move_mode == MOVE_SET.BURBUJA:
		if not bubble: return
		
		audio_comp.play_sound(audio_comp.sound_in_bubble)
		
		
		$CollisionShape2D.disabled = true
		reparent(bubble)
		motion_mode = MotionMode.MOTION_MODE_FLOATING
		position = Vector2(79,0)
		z_index = -1
		velocity = Vector2.ZERO
		
		anim_state = ANIM_STATE_SET.IDLE
		
		bubble.pop_signal.connect(_bubble_pop)
		
	else:
		reparent(first_parent)
		
		z_index = 0
		motion_mode = MotionMode.MOTION_MODE_GROUNDED
		$CollisionShape2D.disabled = false

func _bubble_pop():
	call_deferred("set_move_mode",MOVE_SET.NORMAL)

func _move_on_ground(delta:float, direction:float) -> void:
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
		
		if direction:
			# Aplicamos a velocidade en x por defecto en caso de que non teña unha velocidade maior por terse impulsado dende a burbulla
			if direction > 0:
				if velocity.x < direction * SPEED:
					velocity.x = direction * SPEED
			if direction < 0:
				if velocity.x > direction * SPEED:
					velocity.x = direction * SPEED
			if is_on_floor():
				anim_state = ANIM_STATE_SET.RUN
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		audio_comp.play_sound(audio_comp.sound_jump)
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			anim_state = ANIM_STATE_SET.JUMP

		elif _is_on_wall():
			anim_state = ANIM_STATE_SET.JUMP_WALL
			current_dir *= -1
				
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
	
func dead(is_especial:bool = false):
	call_deferred("set_move_mode", MOVE_SET.NORMAL)
	on_dead_signal.emit()
	$RespawnTimer.start()
	audio_comp.play_sound(audio_comp.sound_dead if not is_especial else audio_comp.sound_dead_especial)
	

func _on_jump_timer_timeout() -> void:
	if is_on_floor():
		anim_state = ANIM_STATE_SET.RUN
	else:
		anim_state = ANIM_STATE_SET.FALL


func _on_respawn_timer_timeout() -> void:
	position = GameController.last_checkpoint_position
