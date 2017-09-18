extends Node

var zoom_factor=1
var zoomx = 1
var zoomy = 1
var zoom_max = 1.5
var camera_x_min = 300
var camera_x_max = 1060
var coeffzoomfinal = 0.5
var timer_thunder = 0
onready var hud_scene = preload("res://Hud/main.tscn")
var curve1 = null
var curve2 = null
var curve3 = null
var path_node = null
var path_node_exist = false
var pathfollow_node = null
var sprite_node = null
var tex_sprite = preload("res://Images/bullet.png")
var script_player2 = preload ("res://Scripts/player2.gd")
var script_bot = preload ("res://Scripts/bot.gd")
var sprite_speed = 16
var path1 = []
var path2 = []
var path3 = []
var position_shooter
var position_target
var direction
var direction_shooter
var fatality1_shoot = 0
var node_player1 = "Player/Player1"
var node_player2 = "Player/Player2"
var node_target
var node_shooter
var node_target_opacity = 1
var target_frame = 27
var fatality_function_name
var node_drone = "enemies/Path2D/PathFollow2D"
var timer_drone_appear
var timer_drone = false
var drone_attack = false


func _ready():
	var hud = hud_scene.instance()
	add_child(hud)
	set_fixed_process(true)
	set_process_input(true)
	randomize()
	fatality_function_name = "fatality_animation_" + str(randi()%2+1)
	timer_drone_appear = randi()%10+2
	get_node(node_drone).get_node("TimerDroneAppear").set_wait_time(timer_drone_appear)
	get_node(node_drone).get_node("TimerDroneAppear").start()

	if (Game.versus_bot):
		get_node(node_player2).set_script(script_bot)
	else:
		get_node(node_player2).set_script(script_player2)


func _input(event):
	var retry = event.is_action_pressed("retry")
	var exit_game = event.is_action_pressed("exit_game")
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
		Game.fatality_ready = false
		Game.fatality_executed = false
		Game.fatality_running = false
		randomize()
		for i in range(0, Game.spawn_timer_array.size()):
			Game.spawn_timer_array[i] = randi()%12+2
		if (Game.ultimate_running_p1):
			Game.ultimate_p1 = 0
			Game.ultimate_running_p1 = false
		if (Game.ultimate_running_p2):
			Game.ultimate_p2 = 0
			Game.ultimate_running_p2 = false

	if (exit_game):
		get_tree().change_scene("res://Hud/MainMenu.tscn")


func _fixed_process(delta):
	# si les deux joueurs sont présents, alors on bouge la caméra et le zoom en fonction de leur position
	if (get_node(".").has_node(node_player1) and get_node(".").has_node(node_player2)):
		var p1 = get_node(node_player1)
		var p2 = get_node(node_player2)
		var newpos = (p1.get_global_pos() + p2.get_global_pos()) * 0.5
		var distance = p1.get_global_pos().distance_to(p2.get_global_pos()) * 2
		var zoom_factor = distance * 0.005
		var zoom = Vector2(1,1) * zoom_factor / 4
		if (zoom.x > zoom_max or zoom.y > zoom_max):
			zoom.x = zoom_max
			zoom.y = zoom_max
			# Centre de l'écran
			newpos = Vector2(670, 690)
		get_node("Camera2D").set_global_pos(newpos)
		if (Vector2(1,1) < zoom):
			get_node("Camera2D").set_zoom(zoom)
	else:
		if(get_node(".").has_node(node_player1)):
			node_shooter = node_player1
		elif(get_node(".").has_node(node_player2)):
			node_shooter = node_player2
		var newpos = (get_node(node_shooter).get_global_pos())
		if (get_node(node_shooter).get_global_pos().x > camera_x_max):
			newpos = Vector2(camera_x_max, get_node(node_shooter).get_global_pos().y)
		elif (get_node(node_shooter).get_global_pos().x < camera_x_min):
			newpos = Vector2(camera_x_min, get_node(node_shooter).get_global_pos().y)
		get_node("Camera2D").set_global_pos(newpos)
		if (get_node("Camera2D").get_zoom().x > 1):
			zoomx = get_node("Camera2D").get_zoom().x - delta*coeffzoomfinal
		if (get_node("Camera2D").get_zoom().y > 1):
			zoomy = get_node("Camera2D").get_zoom().y - delta*coeffzoomfinal
		get_node("Camera2D").set_zoom(Vector2(zoomx, zoomy))

	var current_pos = get_node(node_drone).get_offset()
	if (drone_attack and get_node(node_drone).get_unit_offset() < 1.1):
		get_node(node_drone).set_offset(current_pos + (300*delta))
	elif (get_node(node_drone).get_unit_offset() > 0):
		get_node(node_drone).set_offset(current_pos - (300*delta))

	if (get_node(node_drone).get_unit_offset() <= 0):
		get_node(node_drone).hide()
	else:
		get_node(node_drone).show()

	if (get_node(node_drone).get_unit_offset() >= 1):
		Game.drone_straffing = true
		if (not timer_drone):
			timer_drone = true
			randomize()
			var wait_timer = randi()%5+3
			get_node(node_drone).get_node("TimerDrone").set_wait_time(wait_timer)
			get_node(node_drone).get_node("TimerDrone").start()
	else:
		Game.drone_straffing = false

	# Fatality
	if (Game.fatality_timer != 0 ):
		# Environment
		get_node("Cloud").show()
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
		call(fatality_function_name)
	else:
		get_node("CanvasModulate").set_color(Color("d2b49f"))
		get_node("Fatality/Thunder").hide()
		get_node("Cloud").hide()


func fatality_animation_1():
	if (Game.fatality_ready and Game.fatality_executed and not path_node_exist):
		# Recuperation position des players
		if (Game.health_p1 <= 0):
			position_shooter = get_node(node_player2).get_global_pos()
			direction_shooter = get_node(node_player2).get_node("AnimatedSprite").get_scale().x
			node_shooter = node_player2
			position_target = get_node(node_player1).get_global_pos()
			node_target = node_player1
		elif (Game.health_p2 <= 0):
			position_shooter = get_node(node_player1).get_global_pos()
			direction_shooter = get_node(node_player1).get_node("AnimatedSprite").get_scale().x
			node_shooter = node_player1
			position_target = get_node(node_player2).get_global_pos()
			node_target = node_player2

		# Desactivation collision de la cible
		get_node(node_target).set_layer_mask(0)
		get_node(node_target).set_collision_mask(0)

		# Orientation des sprites du tireur et de la cible
		var deplacement_x = position_target.x - position_shooter.x
		var deplacement_y = position_target.y - position_shooter.y
		if (deplacement_x < 0):
			direction = 1
			if (Game.health_p2 <= 0):
				get_node(node_player1).get_node("AnimatedSprite").set_scale(Vector2(-0.2, 0.2))
			elif (Game.health_p1 <= 0):
				get_node(node_player2).get_node("AnimatedSprite").set_scale(Vector2(0.2, 0.2))
		else:
			direction = -1
			if (Game.health_p2 <= 0):
				get_node(node_player1).get_node("AnimatedSprite").set_scale(Vector2(0.2, 0.2))
			elif (Game.health_p1 <= 0):
				get_node(node_player2).get_node("AnimatedSprite").set_scale(Vector2(-0.2, 0.2))

		curve1 = Curve2D.new()
		curve2 = Curve2D.new()
		curve3 = Curve2D.new()
		path_node = Path2D.new()
		pathfollow_node = PathFollow2D.new()
		sprite_node = Sprite.new()
		# Trajectoire des tirs
		path_node.set_pos(position_shooter)
		# Position du gun du tireur
		path1.append(Vector2(-35*direction, -22))
		# Position de la jambe de la cible
		path1.append(Vector2(deplacement_x+10*direction, deplacement_y + 25))
		# Position du gun du tireur
		path2.append(Vector2(-35*direction, -22))
		# Position de la jambe de la cible
		path2.append(Vector2(deplacement_x+10*direction, deplacement_y + 25))
		# Position du gun du tireur
		path3.append(Vector2(-35*direction, -22))
		# Position de la tete de la cible
		path3.append(Vector2(deplacement_x+10*direction, deplacement_y - 17))

		for point in path1:
			curve1.add_point(point)
		for point in path2:
			curve2.add_point(point)
		for point in path3:
			curve3.add_point(point)
		path_node.set_curve(curve1)
		sprite_node.set_texture(tex_sprite)

		# Ajout sprite bullet aux trajectoires
		get_node(".").add_child(path_node)
		path_node.add_child(pathfollow_node)
		pathfollow_node.add_child(sprite_node)
		pathfollow_node.set_pos(Vector2(0, 0))
		pathfollow_node.set_loop(false)
		pathfollow_node.set_rotate(true)
		pathfollow_node.set_offset(0)
		sprite_node.set_pos(Vector2(0, 0))
		sprite_node.set_scale(Vector2(0.025769, 0.034305))
		path_node_exist = true

	if (Game.fatality_executed and Game.fatality_timer <= 5):
		get_node(node_shooter).get_node("anim").play("idle_weapon")
		Game.fatality_timer = 1
		# Ralentissement du dernier tir
		if (fatality1_shoot == 2):
			sprite_speed = 4
		# Deplacement du tir
		pathfollow_node.set_offset(pathfollow_node.get_offset() + sprite_speed)

		# Quand la balle finit sa trajectoire, soit un nouveau tir, soit fin de la fatality
		if (pathfollow_node.get_unit_offset() > 1):
			fatality1_shoot += 1
			get_node(node_target).get_node("AnimatedSprite").set_frame(target_frame)
			get_node(node_target).get_node("anim").stop(true)
			target_frame += 1
			var curve = "curve" + str(fatality1_shoot+1)
			path_node.set_curve(get(curve))
			pathfollow_node.set_unit_offset(0)
			if (fatality1_shoot == 3):
				sprite_node.queue_free()
				get_node("Fatality/SpotLight").set_pos(Vector2(position_target.x, position_target.y - 260))
				get_node("Fatality/SpotLight").show()
				get_node("Fatality/SpotLight/TimerSpotLight").start()
				Game.fatality_timer = 6
				Game.fatality_ready = false
				Game.fatality_running = false

	if (get_node("Fatality/SpotLight").is_visible() and node_target_opacity >= 0):
		# le perdant s'envole vers les cieux
		node_target_opacity -= 0.005
		get_node(node_target).move_local_y(-2)
		get_node(node_target).set_opacity(node_target_opacity)
		get_node(node_target).get_node("AnimatedSprite").set_frame(30)


func fatality_animation_2():
	sprite_speed = 24
	if (Game.fatality_ready and Game.fatality_executed and not path_node_exist):
		# Recuperation position des players
		if (Game.health_p1 <= 0):
			position_shooter = get_node(node_player2).get_global_pos()
			direction_shooter = get_node(node_player2).get_node("AnimatedSprite").get_scale().x
			node_shooter = node_player2
			position_target = get_node(node_player1).get_global_pos()
			node_target = node_player1
		elif (Game.health_p2 <= 0):
			position_shooter = get_node(node_player1).get_global_pos()
			direction_shooter = get_node(node_player1).get_node("AnimatedSprite").get_scale().x
			node_shooter = node_player1
			position_target = get_node(node_player2).get_global_pos()
			node_target = node_player2

		# Desactivation collision de la cible
		get_node(node_target).set_layer_mask(0)
		get_node(node_target).set_collision_mask(0)

		# Orientation des sprites du tireur et de la cible
		var deplacement_x = position_target.x - position_shooter.x
		var deplacement_y = position_target.y - position_shooter.y
		if (deplacement_x < 0):
			direction = 1
			if (Game.health_p2 <= 0):
				get_node(node_player1).get_node("AnimatedSprite").set_scale(Vector2(-0.2, 0.2))
			elif (Game.health_p1 <= 0):
				get_node(node_player2).get_node("AnimatedSprite").set_scale(Vector2(0.2, 0.2))
		else:
			direction = -1
			if (Game.health_p2 <= 0):
				get_node(node_player1).get_node("AnimatedSprite").set_scale(Vector2(0.2, 0.2))
			elif (Game.health_p1 <= 0):
				get_node(node_player2).get_node("AnimatedSprite").set_scale(Vector2(-0.2, 0.2))

		curve1 = Curve2D.new()
		path_node = Path2D.new()
		pathfollow_node = PathFollow2D.new()
		sprite_node = Sprite.new()
		# Trajectoire des tirs
		path_node.set_pos(position_shooter)

		# Position du gun du tireur
		path1.append(Vector2(-35*direction, -22))
		# Position de la tete de la cible
		path1.append(Vector2(deplacement_x-15*direction, deplacement_y - 40))

		for point in path1:
			curve1.add_point(point)
		path_node.set_curve(curve1)
		sprite_node.set_texture(tex_sprite)

		# Ajout sprite bullet aux trajectoires
		get_node(".").add_child(path_node)
		path_node.add_child(pathfollow_node)
		pathfollow_node.add_child(sprite_node)
		pathfollow_node.set_pos(Vector2(0, 0))
		pathfollow_node.set_loop(false)
		pathfollow_node.set_rotate(true)
		pathfollow_node.set_offset(0)
		sprite_node.set_pos(Vector2(0, 0))
		sprite_node.set_scale(Vector2(0.025769, 0.034305))
		path_node_exist = true

	if (Game.fatality_executed and Game.fatality_timer <= 5):
		get_node(node_shooter).get_node("anim").play("idle_weapon")
		Game.fatality_timer = 1
		pathfollow_node.set_offset(pathfollow_node.get_offset() + sprite_speed)

		# Quand la balle finit sa trajectoire, soit un nouveau tir, soit fin de la fatality
		if (pathfollow_node.get_unit_offset() > 1):
			fatality1_shoot += 1
			get_node(node_target).get_node("AnimatedSprite").set_frame(30)
			get_node(node_target).get_node("anim").stop(true)
			pathfollow_node.set_unit_offset(0)
			if (fatality1_shoot == 6):
				sprite_node.queue_free()
				get_node("Fatality/SpotLight").set_pos(Vector2(position_target.x, position_target.y - 260))
				get_node("Fatality/SpotLight").show()
				get_node("Fatality/SpotLight/TimerSpotLight").start()
				Game.fatality_timer = 6
				Game.fatality_ready = false
				Game.fatality_running = false

	if (get_node("Fatality/SpotLight").is_visible() and node_target_opacity >= 0):
		# le perdant s'envole vers les cieux
		node_target_opacity -= 0.005
		get_node(node_target).move_local_y(-2)
		get_node(node_target).set_opacity(node_target_opacity)
		get_node(node_target).get_node("AnimatedSprite").set_frame(30)


func _on_TimerSpotLight_timeout():
	# Timer du temps d'apparition du halo de la fatality
	get_node("Fatality/SpotLight").hide()
	get_node(node_target).queue_free()


func _on_TimerDrone_timeout():
	# Timer du temps de l'attaque
	drone_attack = false


func _on_TimerDroneAppear_timeout():
	# Timer du temps d'apparition du drone
	drone_attack = true
