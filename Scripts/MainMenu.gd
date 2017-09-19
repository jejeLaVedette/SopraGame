extends Node2D


var index = 0


func _ready():
	set_process_input(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _input(event):
	var exit_game = event.is_action_pressed("exit_game")
	if (exit_game):
		get_tree().quit()

	if (event.is_action("jump_p2") and event.is_pressed() and !event.is_echo()):
		if(index != 0):
			index -= 1
			var x = get_node("Selected").get_pos().x
			var y = get_node("Selected").get_pos().y - 50
			get_node("Selected").set_pos(Vector2(x,y))
	if (event.is_action("crouch_p2") and event.is_pressed() and !event.is_echo()):
		if(index != 3):
			index += 1
			var x = get_node("Selected").get_pos().x
			var y = get_node("Selected").get_pos().y + 50
			get_node("Selected").set_pos(Vector2(x,y))

	if ((event.is_action("shoot_p2") or event.is_action("Enter")) and event.is_pressed() and !event.is_echo()):
		if (index == 0):
			Game.versus_player = false
			Game.versus_bot = true
			get_tree().change_scene("res://stage.tscn")
		if (index == 1):
			Game.versus_player = true
			Game.versus_bot = false
			get_tree().change_scene("res://stage.tscn")
		if (index == 2):
			print("Credits")
		if(index == 3):
			get_tree().quit()
