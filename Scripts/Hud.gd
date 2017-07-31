# Copyright (c) 2016 Calinou and contributors
# Licensed under the MIT license, see `LICENSE.md` for more information.

extends CanvasLayer

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	# Inventory
	get_node("Control/HealthPlayer1").set_value(Game.healthPlayer1)
	get_node("Control/HealthPlayer2").set_value(Game.healthPlayer2)
	
# Spawn a notice at center of screen
# Currently used by shops
func notice(bbcode):
	get_node("Notices/NoticesLabel").set_bbcode("[center]" + bbcode + "[/center]")

# Clears the notice by setting empty text to it
func clear_notice():
	get_node("Notices/NoticesLabel").set_bbcode("")

func _on_HealthPlayer2_value_changed( value ):
	if(value <= 0):
		get_node("Control/HealthPlayer2").set_self_opacity(0)

func _on_HealthPlayer1_value_changed( value ):
	if(value <= 0):
		get_node("Control/HealthPlayer1").set_self_opacity(0)
