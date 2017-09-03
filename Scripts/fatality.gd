extends CanvasLayer

var opacity = 1
var bullet = preload("res://bullet_explode.tscn")

func _ready():
	set_process(true)


func _process(delta):
	if (not Game.defeat_p1 and not Game.defeat_p2):
		opacity -= 0.02
		get_node("Fatality").set_text("Dart HIM !!!")
		get_node("Fatality").set_opacity(opacity)
	else:
		get_node("Fatality").set_text("DARTALITY")
		get_node("Fatality").set_opacity(0.5)


func _on_Timer_timeout():
	get_node("Fatality").hide()
