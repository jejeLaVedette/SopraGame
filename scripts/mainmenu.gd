extends Node2D


var index = 0
var button_separation = 86
var credits = ["Elfide\nDavid", "JeJeLaVedette\nJerome"]
var index_credits = 0

func _ready():
	get_node("Version").set_text(Game.version)
	set_process_input(true)
	# Singleplayer par defaut
	get_node("Selected").set_pos(Vector2(get_node("Selected").get_pos().x, get_node("VBoxContainer/Singleplayer").get_global_pos().y))
	index = 0
	Game.versus_player = false
	Game.versus_bot = true
	get_tree().set_auto_accept_quit(false)


func _input(event):
	var exit_game = event.is_action_pressed("exit_game")
	if (exit_game):
		get_tree().quit()

	if (event.is_action("jump_p2") and event.is_pressed()):
		if(index != 0):
			index -= 1
			var x = get_node("Selected").get_pos().x
			var y = get_node("Selected").get_pos().y - button_separation
			get_node("Selected").set_pos(Vector2(x,y))
	if (event.is_action("crouch_p2") and event.is_pressed()):
		if(index != 4):
			index += 1
			var x = get_node("Selected").get_pos().x
			var y = get_node("Selected").get_pos().y + button_separation
			get_node("Selected").set_pos(Vector2(x,y))

	if ((event.is_action("shoot_p2") or event.is_action("retry")) and event.is_pressed()):
		if (index == 0):
			_on_Singleplayer_released()
			_on_Play_pressed()
		if (index == 1):
			_on_Multiplayer_released()
			_on_Play_pressed()
		if (index == 2):
			_on_Options_released()
		if (index == 3):
			_on_Credits_released()
		if (index == 4):
			_on_Exit_released()


func _on_Singleplayer_released():
	_on_Singleplayer_mouse_enter()


func _on_Multiplayer_released():
	_on_Multiplayer_mouse_enter()


func _on_Options_released():
	_on_Options_mouse_enter()
	get_node("AnimationPlayer").play("Popup_Options")


func _on_Credits_released():
	_on_Credits_mouse_enter()
	get_node("AnimationPlayer").play("Popup_Credits")


func _on_Exit_released():
	_on_Exit_mouse_enter()
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


func _on_Options_mouse_enter():
	get_node("Selected").set_pos(Vector2(get_node("Selected").get_pos().x, get_node("VBoxContainer/Options").get_global_pos().y))
	index = 2


func _on_Credits_mouse_enter():
	get_node("Selected").set_pos(Vector2(get_node("Selected").get_pos().x, get_node("VBoxContainer/Credits").get_global_pos().y))
	index = 3


func _on_Exit_mouse_enter():
	get_node("Selected").set_pos(Vector2(get_node("Selected").get_pos().x, get_node("VBoxContainer/Exit").get_global_pos().y))
	index = 4


func _on_Play_pressed():
	if (index < 2):
		Game.goto_scene("res://stage.tscn")


func _on_Popup_Options_pressed():
	get_node("AnimationPlayer").seek(0, true)
	get_node("AnimationPlayer").play("Popdown_Options")


func _on_Popup_Credits_pressed():
	get_node("AnimationPlayer").seek(0, true)
	index_credits = 0
	get_node("AnimationPlayer").play("Popdown_Credits")


func options():
	get_node("AnimationPlayer").play("Options")


func credits():
	get_node("AnimationPlayer").play("Credits")
	get_node("Popup_Credits/Credits").set_text(credits[index_credits])
	if (index_credits < (credits.size()-1)):
		index_credits += 1
	else:
		index_credits = 0
