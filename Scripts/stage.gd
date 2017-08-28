extends Node

var zoom_factor=1
var zoomx = 1
var zoomy = 1
var coeffzoomfinal = 0.5
var timer_thunder = 0


func _ready():
	set_fixed_process(true)
	set_process_input(true)


func _input(event):
	var retry = Input.is_action_pressed("retry")
	var exit_game = Input.is_action_pressed("exit_game")
	if (retry):
		get_tree().reload_current_scene()
		Game.round_current += 1
		Game.timer = 0
		Game.spawn_healthpack = false
		Game.spawn_gatlinggun = false
		Game.gatlinggun_p1 = false
		Game.gatlinggun_p2 = false
		Game.defeat_p1 = false
		Game.defeat_p2 = false
		Game.health_p1 = Game.health_limit
		Game.health_p2 = Game.health_limit
		Game.fatality_timer = 0
		randomize()
		for i in range(0, Game.spawn_timer_array.size()):
			Game.spawn_timer_array[i] = randi()%12+2

	if (exit_game):
		get_tree().quit()


func _fixed_process(delta):
	# si les deux joueurs sont présents, alors on bouge la caméra et le zoom en fonction de leur position
	if (not Game.defeat_p1 and not Game.defeat_p2):
		var p1 = get_node("Player/Player1")
		var p2 = get_node("Player/Player2")
		var newpos = (p1.get_global_pos() + p2.get_global_pos()) * 0.5
		get_node("Camera2D").set_global_pos(newpos)
		var distance = p1.get_global_pos().distance_to(p2.get_global_pos()) * 2
		var zoom_factor = distance * 0.005
		var zoom = Vector2(1,1) * zoom_factor / 4
		if (Vector2(1,1) < zoom):
			get_node("Camera2D").set_zoom(zoom)
	elif (not Game.defeat_p1):
		var newpos = (get_node("Player/Player1").get_global_pos())
		get_node("Camera2D").set_global_pos(newpos)
		if (get_node("Camera2D").get_zoom().x > 1):
			zoomx = get_node("Camera2D").get_zoom().x - delta*coeffzoomfinal
		if (get_node("Camera2D").get_zoom().y > 1):
			zoomy = get_node("Camera2D").get_zoom().y - delta*coeffzoomfinal
		get_node("Camera2D").set_zoom(Vector2(zoomx, zoomy))
	elif (not Game.defeat_p2):
		var newpos = (get_node("Player/Player2").get_global_pos())
		get_node("Camera2D").set_global_pos(newpos)
		if (get_node("Camera2D").get_zoom().x > 1):
			zoomx = get_node("Camera2D").get_zoom().x - delta*coeffzoomfinal
		if (get_node("Camera2D").get_zoom().y > 1):
			zoomy = get_node("Camera2D").get_zoom().y - delta*coeffzoomfinal
		get_node("Camera2D").set_zoom(Vector2(zoomx, zoomy))

	# Fatality Environnement
	if (Game.fatality_timer != 0 ):
		Game.spawn_gatlinggun = true
		Game.spawn_healthpack = true
		var timer_thunder_max = 2
		if (timer_thunder == 0):
			get_node("Fatality/CanvasFatality").play("CanvasModulateFatality")
			get_node("Fatality/Particles2D").set_emitting(true)
		timer_thunder += delta
		if (timer_thunder >= timer_thunder_max and timer_thunder <= timer_thunder_max + 1):
			if (!get_node("Fatality/Thunder").is_visible()):
				randomize()
				var posx = randi()%1000+100
				get_node("Fatality/Thunder").move_local_x(posx)
				var image_idx = randi()%2+1
				var full_path_image = ("res://Images/Thunder" + str(image_idx) + ".png")
				var texture_thunder = load(full_path_image)
				get_node("Fatality/Thunder").set_texture(texture_thunder)
			get_node("Fatality/Thunder").show()
			get_node("CanvasModulate").set_color(Color("02001f"))
			if (get_node("Fatality/Thunder").get_opacity() == 0):
				get_node("Fatality/Thunder").set_opacity(1)
			else:
				get_node("Fatality/Thunder").set_opacity(0)
		else:
			get_node("Fatality/Thunder").hide()
			get_node("CanvasModulate").set_color(Color(get_node("Fatality/CanvasFatality").get_animation("CanvasModulateFatality").track_get_key_value(0,2)))
	else:
		get_node("CanvasModulate").set_color(Color("d2b49f"))
		get_node("Fatality/Thunder").hide()
