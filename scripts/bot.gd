extends RigidBody2D

# Member variables
var anim = ""
var siding_right = false
var jumping = false
var stopping_jump = false
var shooting = false
var birot = 0
var direction = 1
var GatlingGun_Timer = 0
var GatlingGun_Tempo = 0
var GatlingGun_Modulo = 6
var ultimate_timer_p2 = 0
var vecteur_bullet_x = 15
var vecteur_bullet_y = 0
var linear_velocity_x = 800
var linear_velocity_y = -100
var distanceHorizontalTir = 550
var distanceVerticalTir = 160
var move_left = true
var move_right = false
var jump
var jumpBot
var shoot = false
var special
var crouch
var nb_essai_bot = 0

var rc_left = null
var rc_right = null

var WALK_ACCEL = 800.0
var WALK_DEACCEL = 800.0
var WALK_MAX_VELOCITY = 200.0
var AIR_ACCEL = 200.0
var AIR_DEACCEL = 200.0
var JUMP_VELOCITY = 460
var STOP_JUMP_FORCE = 900.0
var MAX_FLOOR_AIRBORNE_TIME = 0.15
var airborne_time = 1e20
var shoot_time = 1e20
var MAX_SHOOT_POSE_TIME = 0.3

var bullet = preload("res://bullet2.tscn")
var fatality_hud = preload("res://fatality.tscn")
var floor_h_velocity = 0.0
var player
var new_siding_right

func _integrate_forces(s):
	rc_left = get_node("NodeBot/raycast_left")
	rc_right = get_node("NodeBot/raycast_right")
	rc_left.set_enabled(true)
	rc_right.set_enabled(true)

	if (Game.health_p2 > 0 and not Game.fatality_running):
		var lv = s.get_linear_velocity()
		var step = s.get_step()

		var new_anim = anim
		new_siding_right = siding_right
		var wall_side = 0.0

		if (special):
			lv.y -= 100

		# Deapply prev floor velocity
		lv.x -= floor_h_velocity
		floor_h_velocity = 0.0

		# Find the floor (a contact with upwards facing collision normal)
		var found_floor = false
		var floor_index = -1

		for x in range(s.get_contact_count()):
			var ci = s.get_contact_local_normal(x)
			if (ci.dot(Vector2(0, -1)) > 0.6):
				found_floor = true
				floor_index = x
			var cc = s.get_contact_collider_object(x)
			var dp = s.get_contact_local_normal(x)

			if (dp.x > 0.9):
				wall_side = -1.0
			elif (dp.x < -0.9):
				wall_side = 1.0

		var positionJoueurY = get_node("/root/stage/Player/Player1").get_global_pos().y
		var currentPositionY = get_node(".").get_global_pos().y
		var positionJoueurX = get_node("/root/stage/Player/Player1").get_global_pos().x
		var currentPositionX = get_node(".").get_global_pos().x
		
		if (wall_side != 0 and wall_side != direction):
			print(nb_essai_bot)
			if(positionJoueurY<currentPositionY and not _porter_de_tir() and nb_essai_bot < 6):
				jump=true
				jumpBot=true
				nb_essai_bot+=1
			else :
				nb_essai_bot=0
				direction = -direction
				move_left = not move_left
				move_right = not move_right

		# Si il y a du vide alors on fait demi tour
		if (direction > 0 and not rc_left.is_colliding() and rc_right.is_colliding()):
			if(positionJoueurX < currentPositionX and not _porter_de_tir()):
				jump=true
				jumpBot=true
			else :
				direction = -direction
				move_left = false
				move_right = true
		elif (direction < 0 and not rc_right.is_colliding() and rc_left.is_colliding()):
			if(positionJoueurX > currentPositionX and not _porter_de_tir()):
				jump=true
				jumpBot=true
			else :
				direction = -direction
				move_right = false
				move_left = true

		# A good idea when impementing characters of all kinds,
		# compensates for physics imprecission, as well as human reaction delay.
		if (shoot and not shooting and Game.round_started) || (Game.gatlinggun_p2):
			if (Game.gatlinggun_p2):
				crouch = null
				jump = null
				shoot = null
				GatlingGun_Tempo += 1
				vecteur_bullet_x = 30
				vecteur_bullet_y = 30
				linear_velocity_x = 1000
				linear_velocity_y = -(randi()%150+50)
			else:
				GatlingGun_Tempo = GatlingGun_Modulo
				shoot_time = 0
				vecteur_bullet_x = 15
				linear_velocity_x = 800
				linear_velocity_y = -100
				lv.x=0

			if (siding_right):
				birot = 0
			else:
				birot = 180

			var modulo = GatlingGun_Tempo % GatlingGun_Modulo
			if(modulo == 0 and not Game.fatality_ready):
				var bi = bullet.instance()
				var pos = get_pos() + Vector2(-vecteur_bullet_x*direction, vecteur_bullet_y) + get_node("bullet_shoot").get_pos()*Vector2(-direction, -6.0)
				bi.set_pos(pos)
				get_parent().add_child(bi)
				bi.get_node("Sprite").set_rotd(birot)
				bi.set_linear_velocity(Vector2(-linear_velocity_x*direction, linear_velocity_y))
				PS2D.body_add_collision_exception(bi.get_rid(), get_rid()) # Make bullet and this not collide
			elif (Game.fatality_ready and not Game.fatality_executed and found_floor):
				Game.fatality_executed = true
				Game.fatality_running = true

			if(Game.ultimate_p2 >= Game.ultimate_limit):
				ultimate_timer_p2 += 1
				if(ultimate_timer_p2 > 5):
					Game.ultimate_p2 = 0
					ultimate_timer_p2 = 0
					Game.ultimate_running_p2 = false
		else:
			shoot_time += step

		if (found_floor):
			airborne_time = 0.0
		else:
			airborne_time += step # Time it spent in the air

		var on_floor = airborne_time < MAX_FLOOR_AIRBORNE_TIME

		# Process jump
		if (jumping):
			vecteur_bullet_y = 5
			if (lv.y > 0):
				# Set off the jumping flag if going down
				jumping = false
			elif (not jump):
				stopping_jump = true

			if (stopping_jump):
				lv.y += STOP_JUMP_FORCE*step

		if (on_floor):
			# Process logic when character is on floor
			if (move_left and not move_right):
				if (lv.x > -WALK_MAX_VELOCITY):
					lv.x -= WALK_ACCEL*step
			elif (move_right and not move_left):
				if (lv.x < WALK_MAX_VELOCITY):
					lv.x += WALK_ACCEL*step
			else:
				var xv = abs(lv.x)
				xv -= WALK_DEACCEL*step
				if (xv < 0):
					xv = 0
				lv.x = sign(lv.x)*xv

			# Check jump
			if (not jumping and jump):
				lv.y = -JUMP_VELOCITY
				jumping = true
				stopping_jump = false

			# Check siding
			if (lv.x < 0 and move_left):
				new_siding_right = false
				direction = 1
			elif (lv.x > 0 and move_right):
				new_siding_right = true
				direction = -1
			if (jumping):
				new_anim = "jumping"
			elif (abs(lv.x) < 0.1):
				if (shoot_time < MAX_SHOOT_POSE_TIME):
					new_anim = "idle_weapon"
				else:
					new_anim = "idle"
			else:
				if (shoot_time < MAX_SHOOT_POSE_TIME):
					new_anim = "run_weapon"
				else:
					new_anim = "run"
			# Check crouch
			if (crouch):
				new_anim = "crouch"
				get_node("CollisionPolygon2D").set_scale(Vector2(2*direction, 0.8))
				get_node("CollisionPolygon2D").set_pos(Vector2(15*direction, 10))
				vecteur_bullet_y = 30
				lv.x = 0
			else:
				get_node("CollisionPolygon2D").set_scale(Vector2(direction, 1))
				get_node("CollisionPolygon2D").set_pos(Vector2(0, 0))
				vecteur_bullet_y = 0
		else:
			# Process logic when the character is in the air
			if (move_left and not move_right):
				if (lv.x > -WALK_MAX_VELOCITY):
					lv.x -= AIR_ACCEL*step
			elif (move_right and not move_left):
				if (lv.x < WALK_MAX_VELOCITY):
					lv.x += AIR_ACCEL*step
			else:
				var xv = abs(lv.x)
				xv -= AIR_DEACCEL*step
				if (xv < 0):
					xv = 0
				lv.x = sign(lv.x)*xv

			if (lv.y < 0):
				if (shoot_time < MAX_SHOOT_POSE_TIME):
					new_anim = "jumping_weapon"
				else:
					new_anim = "jumping"
			else:
				if (shoot_time < MAX_SHOOT_POSE_TIME):
					new_anim = "falling_weapon"
				else:
					new_anim = "falling"
				vecteur_bullet_y = 15

		# Update siding
		if (new_siding_right != siding_right):
			if (new_siding_right):
				get_node("AnimatedSprite").set_scale(Vector2(0.2*direction, 0.2))
			else:
				get_node("AnimatedSprite").set_scale(Vector2(0.2*direction, 0.2))
			siding_right = new_siding_right

		if (Game.gatlinggun_p2):
			new_anim = "gatlinggun"
			get_node("AnimatedSprite/Sparks").show()
			get_node("AnimatedSprite/Smoke").set_emitting(true)
			get_node("AnimatedSprite/Smoke").show()
		else:
			get_node("AnimatedSprite/Sparks").hide()
			get_node("AnimatedSprite/Smoke").hide()

		# Change animation
		if (new_anim != anim):
			anim = new_anim
			get_node("anim").play(anim)

		shooting = shoot
		shoot=false

		# Apply floor velocity
		if (found_floor):
			floor_h_velocity = s.get_contact_collider_velocity_at_pos(floor_index).x
			lv.x += floor_h_velocity

		# Finally, apply gravity and set back the linear velocity
		lv += s.get_total_gravity()*step
		s.set_linear_velocity(lv)
	elif (Game.fatality_running):
		s.set_linear_velocity(Vector2(0,0))
	
	if jumpBot:
		jump=false
		jumpBot=false


func _on_Timer_timeout():
	if (not Game.fatality_executed):
		#On tire dans la direction du player
		if(_porter_de_tir()):
			var positionJoueurX = get_node("/root/stage/Player/Player1").get_global_pos().x
			var currentPositionX = get_node(".").get_global_pos().x
			if (positionJoueurX < currentPositionX):
				if (move_right):
					direction = -direction
					move_right=false
					move_left=true
			else:
				if (move_left):
					direction = -direction
					move_right=true
					move_left=false
	
			shoot = true

func _porter_de_tir():
	var positionJoueurX = get_node("/root/stage/Player/Player1").get_global_pos().x
	var currentPositionX = get_node(".").get_global_pos().x
	var positionJoueurY = get_node("/root/stage/Player/Player1").get_global_pos().y
	var currentPositionY = get_node(".").get_global_pos().y
	
	if((abs(positionJoueurX-currentPositionX)<distanceHorizontalTir) and (abs(positionJoueurY-currentPositionY)<distanceVerticalTir)):
		return true
	return false

func _ready():
	player = ResourceLoader.load("res://player2.tscn")
	set_fixed_process(true)
	set_process_input(true)


func _fixed_process(delta):
	get_node("/root/stage/HUD/Control/HealthPlayer2").set_value(Game.health_p2)
	get_node("/root/stage/HUD/Control/UltimatePlayer2").set_value(Game.ultimate_p2)
	if (Game.health_p2 > 0):
		Game.health_p2 += delta * 2
		if (Game.health_p1 > 0 and not Game.gatlinggun_p2):
			Game.ultimate_p2 += delta * 5

		if (Game.gatlinggun_p2 and GatlingGun_Timer < 3):
			GatlingGun_Timer += delta
			WALK_MAX_VELOCITY = 1
		else:
			Game.gatlinggun_p2 = false
			WALK_MAX_VELOCITY = 200
	else:
		Game.fatality_timer += delta
		get_node(".").set_sleeping(true)
		if (Game.fatality_timer > 5 ):
			Game.fatality_ready = false
			die_p2()
			Game.defeat_p2 = true
		else:
			Game.fatality_ready = true


func damage(dmg):
	Game.health_p2 -= dmg
	#Fatality
	if (Game.health_p2 <= 0 and not Game.defeat_p2):
		get_parent().add_child(fatality_hud.instance())
		if (not Game.fatality_executed):
			get_node("anim").play("fatality")
	elif (Game.health_p2 > 0):
		get_node("Damage").play("Damage")


func die_p2():
	if (not Game.defeat_p2):
		Game.number_victory_p1 += 1
	if (not Game.fatality_executed):
		get_node("anim").play("defeat")
		get_node("CollisionPolygon2D").set_scale(Vector2(2*direction, 0.7))
		get_node("CollisionPolygon2D").set_pos(Vector2(-5*direction, 20))
