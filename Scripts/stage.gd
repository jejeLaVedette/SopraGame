extends Node

var zoom_factor=1
var zoomx = 1
var zoomy = 1
var coeffzoomfinal = 0.5
var timer_thunder = 0
onready var hud_scene = preload("res://Hud/main.tscn")
var curve1 = Curve2D.new()
var curve2 = Curve2D.new()
var curve3 = Curve2D.new()
var path_node = Path2D.new()
var pathfollow_node = PathFollow2D.new()
var sprite_node = Sprite.new()
var tex_sprite = preload("res://Images/bullet.png")
var sprite_speed = 16
var path1 = []
var path2 = []
var path3 = []
var position_shooter
var position_target
var fatality1_shoot = 0
var player_frame = 27
var node_player1 = "Player/Player1"
var node_player2 = "Player/Player2"
var node_target


func _ready():
	var hud = hud_scene.instance()
	add_child(hud)
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
		Game.gatlinggun_bot = false
		Game.defeat_p1 = false
		Game.defeat_bot = false
		Game.health_p1 = Game.health_limit
		Game.health_bot = Game.health_limit
		Game.fatality_timer = 0
		Game.fatality_ready = false
		Game.fatality_executed = false
		Game.fatality_running = false
		randomize()
		for i in range(0, Game.spawn_timer_array.size()):
			Game.spawn_timer_array[i] = randi()%12+2

	if (exit_game):
		get_tree().quit()


func _fixed_process(delta):
	# si les deux joueurs sont présents, alors on bouge la caméra et le zoom en fonction de leur position
	if (not Game.defeat_p1 and not Game.defeat_p2):
		var p1 = get_node(node_player1)
		var p2 = get_node(node_player2)

	if (not Game.defeat_p1 and not Game.defeat_bot):
		var p1 = get_node(node_player1)
		var bot = get_node("Player/Bot")
		var newpos = (p1.get_global_pos() + bot.get_global_pos()) * 0.5
		get_node("Camera2D").set_global_pos(newpos)
		var distance = p1.get_global_pos().distance_to(bot.get_global_pos()) * 2
		var zoom_factor = distance * 0.005
		var zoom = Vector2(1,1) * zoom_factor / 4
		if (Vector2(1,1) < zoom):
			get_node("Camera2D").set_zoom(zoom)
	elif (not Game.defeat_p1):
		var newpos = (get_node(node_player1).get_global_pos())
		get_node("Camera2D").set_global_pos(newpos)
		if (get_node("Camera2D").get_zoom().x > 1):
			zoomx = get_node("Camera2D").get_zoom().x - delta*coeffzoomfinal
		if (get_node("Camera2D").get_zoom().y > 1):
			zoomy = get_node("Camera2D").get_zoom().y - delta*coeffzoomfinal
		get_node("Camera2D").set_zoom(Vector2(zoomx, zoomy))
	elif (not Game.defeat_p2):
		var newpos = (get_node(node_player2).get_global_pos())
	elif (not Game.defeat_bot):
		var newpos = (get_node("Player/Bot").get_global_pos())
		get_node("Camera2D").set_global_pos(newpos)
		if (get_node("Camera2D").get_zoom().x > 1):
			zoomx = get_node("Camera2D").get_zoom().x - delta*coeffzoomfinal
		if (get_node("Camera2D").get_zoom().y > 1):
			zoomy = get_node("Camera2D").get_zoom().y - delta*coeffzoomfinal
		get_node("Camera2D").set_zoom(Vector2(zoomx, zoomy))

	# Fatality
	if (Game.fatality_timer != 0 ):
		# Environment
		Game.spawn_gatlinggun = true
		Game.spawn_healthpack = true
		var timer_thunder_max = 2
		if (timer_thunder == 0):
			get_node("Fatality/CanvasFatality").play("CanvasModulateFatality")
			get_node("Fatality/Particles2D Left").set_emitting(true)
			get_node("Fatality/Particles2D Right").set_emitting(true)
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

		# Animation
		if (Game.fatality_ready and Game.fatality_executed and Game.fatality_running):
			Game.fatality_running = false
			if (Game.health_p1 <= 0):
				position_shooter = get_node(node_player2).get_global_pos()
				position_target = get_node(node_player1).get_global_pos()
				node_target = node_player1
			elif (Game.health_p2 <= 0):
				position_shooter = get_node(node_player1).get_global_pos()
				position_target = get_node(node_player2).get_global_pos()
				node_target = node_player2

			var deplacement_x = position_target.x - position_shooter.x
			var deplacement_y = position_target.y - position_shooter.y

			path_node.set_pos(position_shooter)
			# LegShot
			path1.append(Vector2(-15, -20))
			path1.append(Vector2(deplacement_x + 10, deplacement_y + 20))
			# LegShot
			path2.append(Vector2(-15, -20))
			path2.append(Vector2(deplacement_x + 10, deplacement_y + 20))
			# HeadShot
			path3.append(Vector2(-15, -20))
			path3.append(Vector2(deplacement_x + 10, deplacement_y - 20))

			for point in path1:
				curve1.add_point(point)
			for point in path2:
				curve2.add_point(point)
			for point in path3:
				curve3.add_point(point)
			path_node.set_curve(curve1)
			sprite_node.set_texture(tex_sprite)

			get_node(".").add_child(path_node)
			path_node.add_child(pathfollow_node)
			pathfollow_node.add_child(sprite_node)
			pathfollow_node.set_pos(Vector2(0, 0))
			pathfollow_node.set_loop(false)
			pathfollow_node.set_rotate(true)
			pathfollow_node.set_offset(0)
			sprite_node.set_pos(Vector2(0, 0))
			sprite_node.set_scale(Vector2(0.025769, 0.034305))

		if (Game.fatality_executed and Game.fatality_timer <= 5):
			Game.fatality_timer = 1
			pathfollow_node.set_offset(pathfollow_node.get_offset() + sprite_speed)
			if (pathfollow_node.get_unit_offset() > 1):
				fatality1_shoot += 1
				get_node(node_target).get_node("AnimatedSprite").set_frame(player_frame)
				get_node(node_target).get_node("anim").stop(true)
				player_frame += 1
				var curve = "curve" + str(fatality1_shoot+1)
				path_node.set_curve(get(curve))
				pathfollow_node.set_unit_offset(0)
				if (fatality1_shoot == 3):
					sprite_node.queue_free()
					Game.fatality_timer = 6
					Game.fatality_ready = false
	else:
		get_node("CanvasModulate").set_color(Color("d2b49f"))
		get_node("Fatality/Thunder").hide()
