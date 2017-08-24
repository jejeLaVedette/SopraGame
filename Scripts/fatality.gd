extends CanvasLayer

func _ready():
	set_fixed_process(true)


func _fixed_process(delta):
	if (get_node("/root/stage/Player").has_node("Player1") and get_node("/root/stage/Player").has_node("Player2")):
		get_node("Fatality").set_text("Dart HIM !!!")
	else:
		get_node("Fatality").set_text("FATALITY")


func _on_Timer_timeout():
	get_node("Fatality").hide()
