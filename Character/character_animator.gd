extends AnimatedSprite2D


var parent

func _ready() -> void:
	parent = get_parent()


func _process(_delta: float) -> void:
	if parent == null: return
	
	if parent.anim_state == parent.ANIM_STATE_SET.RUN:
		if parent.move_mode == parent.MOVE_SET.BURBUJA:
			animation = "moveBubbleL" if parent.current_dir < 0 else "moveBubbleR"
		else:
			animation = "runL" if parent.current_dir < 0 else "runR"
			play()
	elif parent.anim_state == parent.ANIM_STATE_SET.JUMP and animation not in ["jumpL","jumpR"]:
		animation = "jumpL" if parent.current_dir < 0 else "jumpR"
		play()
	elif parent.anim_state == parent.ANIM_STATE_SET.IDLE:
		
		if parent.move_mode == parent.MOVE_SET.BURBUJA:
			animation = "idleBubbleL" if parent.current_dir < 0 else "idleBubbleR"
		else:
			animation = "idleL" if parent.current_dir < 0 else "idleR"
	elif parent.anim_state == parent.ANIM_STATE_SET.WALL:
		animation = "slideL" if parent.current_dir < 0 else "slideR"
	elif parent.anim_state in [parent.ANIM_STATE_SET.FALL,parent.ANIM_STATE_SET.JUMP_WALL]:
		animation = "fallL" if parent.current_dir < 0 else "fallR"
		
