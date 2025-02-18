class_name TransitionManagerClass extends CanvasLayer

signal mid_transition_signal
signal end_transition_signal

enum Transitions { None, FADE }

const TRANSITION_DICT = {
	Transitions.FADE: ["Fade_in","Fade_out"],
}

var current_transition = null

func _ready() -> void:
	$AnimationPlayer.animation_finished.connect(self._animation_finish)

func _animation_finish(anim_name:StringName):
	if current_transition == null:
		end_transition_signal.emit()
	else:
		mid_transition_signal.emit()

func start_transition(transition:Transitions = Transitions.FADE) -> bool:
	if current_transition != null or transition == Transitions.None:
		return false
		
	current_transition = transition
	$AnimationPlayer.play(TRANSITION_DICT[current_transition][0])
	
	return true

func end_transition(transition:Transitions = Transitions.None) -> bool:
	if transition != Transitions.None:
		current_transition = transition
		
	if current_transition == null:
		return false
		
	$AnimationPlayer.play(TRANSITION_DICT[current_transition][1])
	current_transition = null
	
	return true
