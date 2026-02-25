class_name StateMachine
extends RefCounted

enum State {
	IDLE,
	RUN,
	JUMP,
	FALL,
	BUBBLE_IDLE,
	BUBBLE_MOVE,
	BUBBLE_JUMP,
	SLICE,
	SLICE_JUMP
}

var character: Player
var current_state: BaseState
var old_state: State
var states: Dictionary = {}
var state_data: Dictionary = {}


func _init(player: Player) -> void:
	character = player
	register_state(State.IDLE, IdleState.new(player))
	register_state(State.RUN, RunState.new(player))
	register_state(State.JUMP, JumpState.new(player))
	register_state(State.FALL, FallState.new(player))
	register_state(State.BUBBLE_IDLE, BubbleIdleState.new(player))
	register_state(State.BUBBLE_MOVE, BubbleMoveState.new(player))
	register_state(State.BUBBLE_JUMP, BubbleJumpState.new(player))
	register_state(State.SLICE, SliceState.new(player))
	register_state(State.SLICE_JUMP, SliceJumpState.new(player))
	
	change_state(State.IDLE)


## Registra un estado en la máquina
func register_state(state_name: State, state: BaseState) -> void:
	states[state_name] = state


## Cambia al estado especificado
func change_state(state_name: State, data: Dictionary = {}) -> void:
	if not states.has(state_name):
		push_error("El estado '%s' no está registrado en la máquina de estados" % State.keys()[state_name])
		return
		
	# Llamar on_end del estado actual
	if current_state != null:
		current_state.on_end()
		
	# Guardar datos para el nuevo estado
	state_data = data
	
	var current_state_name = get_current_state_name()
	if old_state != current_state_name:
		print("State changed to: %s" % State.keys()[current_state_name])
		old_state = current_state_name
		
	# Cambiar al nuevo estado
	current_state = states[state_name]
	current_state.on_start(state_data)


## Obtiene el estado actual
func get_current_state() -> BaseState:
	return current_state


## Obtiene el nombre del estado actual
func get_current_state_name() -> State:
	for state_name in states:
		if states[state_name] == current_state:
			return state_name
	return State.IDLE


## Gestiona el input del estado actual
func input(event: InputEvent) -> void:
	if current_state != null:
		current_state.on_input(event)


## Procesa la lógica de física del estado actual
func physics_process(delta: float) -> void:
	if current_state != null:
		current_state.on_physics_process(delta)


## Procesa la lógica general del estado actual
func process(delta: float) -> void:
	if current_state != null:
		current_state.on_process(delta)


## Verifica si está en un estado específico
func is_state(state_name: State) -> bool:
	return get_current_state_name() == state_name
