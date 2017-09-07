extends Control

func _on_Quit_pressed():
	get_tree().quit()

func _on_NewGame_pressed():
	Game.versus_player = true
	Game.versus_bot = false
	get_tree().change_scene("res://stage.tscn")
	
func _ready():
	pass

func _on_Campagne_pressed():
	Game.versus_player = false
	Game.versus_bot = true
	get_tree().change_scene("res://stage.tscn")
