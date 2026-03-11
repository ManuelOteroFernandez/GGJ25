class_name Player extends CharacterBody2D

signal on_dead_signal

enum MOVE_SET { GROUND, BURBUJA }
enum ANIM_STATE_SET { 
	JUMP, 
	IDLE, 
	RUN , 
	FALL, 
	SLICE, 
	JUMP_SLICE,
	BUBBLE_IDLE,
	BUBBLE_MOVE,
	BUBBLE_JUMP,
}


const SPEED = 50000.0
const JUMP_VELOCITY = -1650.0
const WEIGHT = 2.6

const MIN_HEIGHT_SLICE = 384

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var shape_cat: CapsuleShape2D = load("res://Character/shapeCat.tres")
@onready var shape_slide: CapsuleShape2D = load("res://Character/shape_slide.tres")

@onready var ray_der: RayCast2D = $RayCastDer
@onready var ray_izq: RayCast2D = $RayCastIzq

@onready var audio_comp = $AudioStreamPlayer2D
@onready var first_parent = get_parent()

@onready var state_machine: StateMachine = StateMachine.new(self)

var _last_bubble_collided_id:int

var is_jumping:bool = false
var move_mode:MOVE_SET = MOVE_SET.GROUND
var current_dir = 1
var anim_state = ANIM_STATE_SET.IDLE


func rotate_with_surface(full_rotate: bool = false) -> void:
	var ray_start: Vector2 = global_position + current_dir * Vector2(collision_shape.shape.mid_height / 2,0).rotated(rotation)
	var ray_end := ray_start + Vector2(0,256).rotated(rotation)
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(ray_start, ray_end)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	
	if not result.is_empty():
		var normal = result.get("normal", Vector2.UP)
		var angulo_personaje = normal.angle() + deg_to_rad(90)
		
		if full_rotate:
			rotation = angulo_personaje
			var dist_to_floor = calculate_floor_distance()
			if dist_to_floor > 1 and dist_to_floor != INF:
				global_position += Vector2(0, dist_to_floor).rotated(rotation)

		else:
			rotation = lerp_angle(rotation, angulo_personaje, 0.2)

func calculate_floor_distance() -> float:
	var ray_start := global_position
	var ray_end := ray_start + Vector2(0,128).rotated(rotation)
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(ray_start, ray_end)
	query.exclude = [self]
	query.hit_from_inside = true
	var result := space_state.intersect_ray(query)
			
	if not result.is_empty():
		var collision_point = result.get("position", Vector2.ZERO)
		return global_position.distance_to(collision_point) - collision_shape.shape.radius
	
	return INF


func is_near_floor() -> bool:
	var ray_start := global_position + Vector2(-collision_shape.shape.mid_height,128).rotated(rotation)
	var ray_end := global_position + Vector2(collision_shape.shape.mid_height,128).rotated(rotation)
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(ray_start, ray_end)
	query.exclude = [self]
	query.hit_from_inside = true
	var result := space_state.intersect_ray(query)
			
	return not result.is_empty()


func get_bubble() -> Bubble:
	var bubble = get_parent() as Bubble
	return bubble if bubble else null


func _input(event: InputEvent) -> void:
	state_machine.input(event)
		
		
func _physics_process(delta: float) -> void:
	state_machine.physics_process(delta)
	#print(velocity)


func _process(delta: float) -> void:
	state_machine.process(delta)
	

func check_collision_with_bubble() -> Bubble:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if not collision: continue
		
		var node_collision = collision.get_collider() as Node
		if node_collision.is_in_group("Bubbles"):
			
			var node_id = node_collision.get_instance_id()
			if node_id == _last_bubble_collided_id:
				continue
				
			_last_bubble_collided_id = node_id
			
			return node_collision as Bubble

	return null


func set_move_bubble(bubble: Bubble) -> void:
	if move_mode == MOVE_SET.GROUND:
		if not bubble: return
				
		audio_comp.play_sound(audio_comp.sound_in_bubble)
		
		collision_shape.disabled = true
		reparent(bubble)
		bubble.add_to_group("Player")
		motion_mode = MotionMode.MOTION_MODE_FLOATING
		position = Vector2(0,79)
		z_index = -1
		velocity = Vector2.ZERO
		
		anim_state = ANIM_STATE_SET.IDLE
		
		bubble.pop_signal.connect(bubble_pop)

		state_machine.change_state(StateMachine.State.BUBBLE_IDLE)
		move_mode = MOVE_SET.BURBUJA


func bubble_pop():
	reparent(first_parent)
	state_machine.change_state(StateMachine.State.FALL)

func set_move_ground() -> void:
	if move_mode == MOVE_SET.BURBUJA:
		reparent(first_parent)
		
		z_index = 0
		motion_mode = MotionMode.MOTION_MODE_GROUNDED
		collision_shape.disabled = false
		move_mode = MOVE_SET.GROUND

	
func check_is_on_wall() -> bool:
	if is_on_floor(): 
		return false
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position, 
		global_position + Vector2(0, MIN_HEIGHT_SLICE)
	)
	var result = space_state.intersect_ray(query)
	if result and result.get("collider", null) and result["collider"].is_in_group("Ground"):
		return false
		
	if ray_der.is_colliding():
		return current_dir == 1 
		
	if ray_izq.is_colliding():
		return current_dir == -1
		
	return false
	
	
func dead(is_especial:bool = false):
	on_dead_signal.emit()
	$RespawnTimer.start()
	audio_comp.play_sound(audio_comp.sound_dead if not is_especial else audio_comp.sound_dead_especial)


func apply_move_horizontal(delta: float) -> void:
	var reduce_velocity = false
	var direction := Input.get_axis("move_left", "move_right")
		
	if direction:
		current_dir = direction
		
		var new_velocity_x = direction * SPEED * delta
		if abs(new_velocity_x) < abs(velocity.x):
			reduce_velocity = true
		else:
			velocity.x = new_velocity_x
	
	if not direction or reduce_velocity:
		velocity.x = move_toward(velocity.x, 0, (SPEED/20) * delta)


func apply_gravity(delta: float) -> void:
	velocity += get_gravity() * WEIGHT * delta
