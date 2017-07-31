
extends Node

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	set_process_input(true)

func _input(event):
	var retry = Input.is_action_pressed("retry")

	if (retry):
		get_tree().reload_current_scene()
