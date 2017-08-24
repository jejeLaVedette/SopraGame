extends CanvasLayer

var rounded_timer = 0
var round_initial_pos
var tex_ultimate_ready = preload("res://Images/UltimateReady.png")
var tex_loading_ultimate = preload("res://Images/UltimateBar.png")
var gatlinggun = preload("res://gatlinggun.tscn")
var healthpack = preload("res://healthpack.tscn")


# Spawn a notice at center of screen
# Currently used by shops
func notice(bbcode):
	get_node("Notices/NoticesLabel").set_bbcode("[center]" + bbcode + "[/center]")


# Clears the notice by setting empty text to it
func clear_notice():
	get_node("Notices/NoticesLabel").set_bbcode("")


func _on_HealthPlayer2_value_changed( value ):
	if(value <= 0):
		get_node("Control/HealthPlayer2").set_value(0)


func _on_HealthPlayer1_value_changed( value ):
	if(value <= 0):
		get_node("Control/HealthPlayer1").set_value(0)


func _ready():
	set_process(true)


func _process(delta):
	Game.timer += delta
	rounded_timer = round(Game.timer)

	if (Game.number_victory_p1 > 0):
		get_node("NbVictoryP1").show()
		get_node("NbVictoryP1").set_text(str("W:", Game.number_victory_p1))
	else:
		get_node("NbVictoryP1").hide()
	if (Game.number_victory_p2 > 0):
		get_node("NbVictoryP2").show()
		get_node("NbVictoryP2").set_text(str("W:", Game.number_victory_p2))
	else:
		get_node("NbVictoryP2").hide()

	get_node("Round").set_text(str("ROUND ", Game.round_current))
	if (rounded_timer < 2):
		get_node("Timer").hide()
		get_node("Round").show()
	else:
		get_node("Round").hide()
		get_node("Timer").show()
		if(not Game.spawn_gatlinggun and rounded_timer == Game.spawn_timer):
			var gi = gatlinggun.instance()
			randomize()
			var posx_gi = randi()%1000+100
			gi.set_pos(Vector2(posx_gi, 200))
			get_node("/root/stage").add_child(gi)
			Game.spawn_gatlinggun = true
			randomize()
			var hi = healthpack.instance()
			var posx_hi = randi()%1000+100
			hi.set_pos(Vector2(posx_hi, 100))
			get_node("/root/stage").add_child(hi)

		if (get_node("/root/stage/Player").has_node("Player1") and get_node("/root/stage/Player").has_node("Player2")):
			get_node("Timer").set_text(str(rounded_timer-1))


func _on_UltimatePlayer1_value_changed( value ):
	if(value >= Game.ultimate_limit):
		get_node("Control/UltimatePlayer1").set_value(Game.ultimate_limit)
		get_node("Control/UltimatePlayer1").set_progress_texture(tex_ultimate_ready)
	else:
		get_node("Control/UltimatePlayer1").set_progress_texture(tex_loading_ultimate)


func _on_UltimatePlayer2_value_changed( value ):
	if(value >= Game.ultimate_limit):
		get_node("Control/UltimatePlayer2").set_value(Game.ultimate_limit)
		get_node("Control/UltimatePlayer2").set_progress_texture(tex_ultimate_ready)
	else:
		get_node("Control/UltimatePlayer2").set_progress_texture(tex_loading_ultimate)
