extends AnimatedSprite2D


var parent

func _ready() -> void:
	parent = get_parent()


func _process(_delta: float) -> void:
	if parent == null: return
	
	if parent.anim_state == parent.ANIM_STATE_SET.RUN:
		animation = "runL" if parent.current_dir < 0 else "runR"

	elif parent.anim_state == parent.ANIM_STATE_SET.JUMP and animation not in ["jumpL","jumpR"]:
		animation = "jumpL" if parent.current_dir < 0 else "jumpR"

	elif parent.anim_state == parent.ANIM_STATE_SET.IDLE:
		animation = "idleL" if parent.current_dir < 0 else "idleR"

	elif parent.anim_state == parent.ANIM_STATE_SET.SLICE:
		animation = "slideL" if parent.current_dir < 0 else "slideR"

	elif parent.anim_state in [parent.ANIM_STATE_SET.FALL, parent.ANIM_STATE_SET.JUMP_SLICE]:
		animation = "fallL" if parent.current_dir < 0 else "fallR"
	
	elif parent.anim_state == parent.ANIM_STATE_SET.BUBBLE_IDLE:
		animation = "idleBubbleL" if parent.current_dir < 0 else "idleBubbleR"

	elif parent.anim_state == parent.ANIM_STATE_SET.BUBBLE_MOVE:
		animation = "moveBubbleL" if parent.current_dir < 0 else "moveBubbleR"

	play()
