extends AnimatedSprite2D


var parent: Player

func _ready() -> void:
	parent = get_parent() as Player
	if parent == null: return
	parent.state_changed_signal.connect(_on_state_changed)


func _process(_delta: float) -> void:
	flip_h = parent.current_dir < 0


func _on_state_changed(new_state: StateMachine.State) -> void:
	match new_state:
		StateMachine.State.RUN:
			animation = "run"
		StateMachine.State.JUMP:
			animation = "jump"
		StateMachine.State.IDLE:
			animation = "idle"
		StateMachine.State.SLICE:
			animation = "slide"
		StateMachine.State.FALL, StateMachine.State.SLICE_JUMP:
			animation = "fall"
		StateMachine.State.BUBBLE_IDLE:
			animation = "idleBubble"
		StateMachine.State.BUBBLE_MOVE:
			animation = "moveBubble"
		StateMachine.State.BUBBLE_JUMP:
			animation = "jump"
	play()
