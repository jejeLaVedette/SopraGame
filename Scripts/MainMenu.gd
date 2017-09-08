extends Control


func _ready():
	set_process_input(true)

func _on_Quit_pressed():
	get_tree().quit()

func _on_NewGame_pressed():
	Game.versus_player = true
	Game.versus_bot = false
	get_tree().change_scene("res://stage.tscn")

func _on_Campagne_pressed():
	Game.versus_player = false
	Game.versus_bot = true
	get_tree().change_scene("res://stage.tscn")

func _input(event):
	var exit_game = Input.is_action_pressed("exit_game")
	if (exit_game):
		get_tree().quit()