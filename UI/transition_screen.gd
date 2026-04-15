class_name TransitionScreen
extends ColorRect

signal fade_out_finished
signal fade_in_finished

func fade_in(duration:float):
	modulate.a = 0
	visible = true
	var tween := get_tree().create_tween()
	tween.tween_property(self,"modulate:a", 1, duration)

	await tween.finished

	emit_signal("fade_in_finished")

func fade_out(duration:float):
	modulate.a = 1
	visible = true
	var tween := get_tree().create_tween()
	tween.tween_property(self,"modulate:a", 0, duration)
	
	await tween.finished

	emit_signal("fade_out_finished")
	visible = false
