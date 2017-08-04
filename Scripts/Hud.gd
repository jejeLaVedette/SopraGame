extends CanvasLayer

var rounded_timer = 0

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
	get_node("Timer").set_text(str(rounded_timer))
	get_node("NbVictoryP1").set_text(str(Game.number_player1_victory))
	get_node("NbVictoryP2").set_text(str(Game.number_player2_victory))
	get_node("Round").set_text(str("ROUND ", Game.round_current))
	if (rounded_timer < 3):
		get_node("Round").show()
		get_node("Round").set_size(Vector2(rounded_timer, rounded_timer))
	else:
		get_node("Round").hide()
