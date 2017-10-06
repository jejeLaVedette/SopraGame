extends Node2D


var index = 0


func _ready():
	set_process_input(true)
	get_node("Selected").set_pos(Vector2(get_node("Selected").get_pos().x, get_node("VBoxContainer/Singleplayer").get_global_pos().y))
	index = 0
	Game.versus_player = false
	Game.versus_bot = true


func _input(event):
	var exit_game = event.is_action_pressed("exit_game")
	if (exit_game):
		get_tree().quit()

	if (event.is_action("jump_p2") and event.is_pressed()):
		if(index != 0):
			index -= 1
			var x = get_node("Selected").get_pos().x
			var y = get_node("Selected").get_pos().y - 65
			get_node("Selected").set_pos(Vector2(x,y))
	if (event.is_action("crouch_p2") and event.is_pressed()):
		if(index != 3):
			index += 1
			var x = get_node("Selected").get_pos().x
			var y = get_node("Selected").get_pos().y + 65
			get_node("Selected").set_pos(Vector2(x,y))

	if ((event.is_action("shoot_p2") or event.is_action("retry")) and event.is_pressed()):
		if (index == 0):
			_on_SinglePlayer_released()
			_on_Fight_pressed()
		if (index == 1):
			_on_Multiplayer_released()
			_on_Fight_pressed()
		if (index == 2):
			_on_Credits_released()
		if(index == 3):
			_on_Exit_released()


func _on_Singleplayer_released():
	_on_Singleplayer_mouse_enter()


func _on_Multiplayer_released():
	_on_Multiplayer_mouse_enter()


func _on_Credits_released():
	print("Credits")


func _on_Exit_released():
	get_tree().quit()


func _on_Singleplayer_mouse_enter():
	get_node("Selected").set_pos(Vector2(get_node("Selected").get_pos().x, get_node("VBoxContainer/Singleplayer").get_global_pos().y))
	index = 0
	Game.versus_player = false
	Game.versus_bot = true


func _on_Multiplayer_mouse_enter():
	get_node("Selected").set_pos(Vector2(get_node("Selected").get_pos().x, get_node("VBoxContainer/Multiplayer").get_global_pos().y))
	index = 1
	Game.versus_player = true
	Game.versus_bot = false


func _on_Credits_mouse_enter():
	get_node("Selected").set_pos(Vector2(get_node("Selected").get_pos().x, get_node("VBoxContainer/Credits").get_global_pos().y))
	index = 2


func _on_Exit_mouse_enter():
	get_node("Selected").set_pos(Vector2(get_node("Selected").get_pos().x, get_node("VBoxContainer/Exit").get_global_pos().y))
	index = 3


func _on_Fight_pressed():
	if (index < 2):
		get_tree().change_scene("res://stage.tscn")
