class_name RunState
extends BaseState

var direction: float = 0

func on_start(_data: Dictionary = {}) -> void:
	character.set_move_ground()
	
	character.anim_state = Player.ANIM_STATE_SET.RUN

	var is_floor_horizontal = check_floor_is_horizontal()
	character.rotate_with_surface(not is_floor_horizontal)
	

func on_end() -> void:
	pass


func on_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("jump"):
		character.state_machine.change_state(StateMachine.State.JUMP)


func on_physics_process(delta: float) -> void:

	if not character.is_near_floor() and character.velocity.y >= 0:
		character.state_machine.change_state(StateMachine.State.FALL)
		return

	direction = Input.get_axis("move_left", "move_right")
	
	if character.velocity.x == 0 and direction == 0:
		character.state_machine.change_state(StateMachine.State.IDLE)
		return
		
	move(delta)


func move(delta: float) -> void:
	character.rotate_with_surface()

	if abs(character.rotation_degrees) < 2:
		character.apply_move_horizontal(delta)
		if character.calculate_floor_distance() > 1:
			character.apply_gravity(delta)
	else:
			
		var movement_direction = Vector2.RIGHT.rotated(character.rotation)
			
		if direction:
			character.current_dir = direction
			character.velocity = movement_direction * direction * Player.SPEED * delta
			if character.calculate_floor_distance() > 1:
				if character.velocity.y < 0:
					character.velocity.y = 0
				elif character.velocity.y > 0:
					character.apply_gravity(delta)
		else:
			character.velocity = character.velocity.move_toward(Vector2.ZERO, Player.SPEED * delta)
	
	character.move_and_slide()

	var bubble_collided = character.check_collision_with_bubble()
	if bubble_collided:
		character.set_move_bubble(bubble_collided)


func check_floor_is_horizontal() -> bool:
	var ray_start := character.global_position
	var ray_end := character.global_position + Vector2(0,128)
	var space_state = character.get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(ray_start, ray_end)
	query.exclude = [character]
	query.hit_from_inside = true
	var result := space_state.intersect_ray(query)
			
	if not result.is_empty():
		var normal = result.get("normal", Vector2.UP)
		return abs(normal.angle_to(Vector2.UP)) < deg_to_rad(10) # Considera el suelo horizontal si el ángulo es menor a 10 grados
	
	return false


func on_process(_delta: float) -> void:
	pass
