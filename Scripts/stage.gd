extends Node

var zoom_factor=1
var zoomx = 1
var zoomy = 1
var coeffzoomfinal = 0.5


func _ready():
	set_fixed_process(true)
	set_process_input(true)


func _input(event):
	var retry = Input.is_action_pressed("retry")
	if (retry):
		get_tree().reload_current_scene()
		Game.round_current += 1
		Game.timer = 0
		Game.spawn_gatlinggun = false
		Game.gatlinggun_p1 = false
		Game.gatlinggun_p2 = false
		Game.health_p1 = Game.health_limit
		Game.health_p2 = Game.health_limit
		randomize()
		Game.spawn_timer = randi()%12+2


func _fixed_process(delta):
	# si les deux joueurs sont présents, alors on bouge la caméra et le zoom en fonction de leur position
	if (get_node(".").has_node("Player1") and get_node(".").has_node("Player2")):
		var p1 = get_node("Player1")
		var p2 = get_node("Player2")
		var newpos = (p1.get_global_pos() + p2.get_global_pos()) * 0.5
		get_node("Camera2D").set_global_pos(newpos)
		var distance = p1.get_global_pos().distance_to(p2.get_global_pos()) * 2
		var zoom_factor = distance * 0.005
		var zoom = Vector2(1,1) * zoom_factor / 4
		if (Vector2(1,1) < zoom):
			get_node("Camera2D").set_zoom(zoom)
	elif (get_node(".").has_node("Player1")):
		var newpos = (get_node("Player1").get_global_pos())
		get_node("Camera2D").set_global_pos(newpos)
		if (get_node("Camera2D").get_zoom().x > 1):
			zoomx = get_node("Camera2D").get_zoom().x - delta*coeffzoomfinal
		if (get_node("Camera2D").get_zoom().y > 1):
			zoomy = get_node("Camera2D").get_zoom().y - delta*coeffzoomfinal
		get_node("Camera2D").set_zoom(Vector2(zoomx, zoomy))
	elif (get_node(".").has_node("Player2")):
		var newpos = (get_node("Player2").get_global_pos())
		get_node("Camera2D").set_global_pos(newpos)
		if (get_node("Camera2D").get_zoom().x > 1):
			zoomx = get_node("Camera2D").get_zoom().x - delta*coeffzoomfinal
		if (get_node("Camera2D").get_zoom().y > 1):
			zoomy = get_node("Camera2D").get_zoom().y - delta*coeffzoomfinal
		get_node("Camera2D").set_zoom(Vector2(zoomx, zoomy))
