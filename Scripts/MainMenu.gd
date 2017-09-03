extends Control

func _on_Quit_pressed():
	get_tree().quit()

func _on_NewGame_pressed():
	get_tree().change_scene("res://stage.tscn")
	
func _ready():
	pass

func _on_Campagne_pressed():
	get_tree().change_scene("res://campagne.tscn")
