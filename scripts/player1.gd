extends RigidBody2D

# Member variables
var anim = ""
var siding_left = false
var jumping = false
var stopping_jump = false
var shooting = false
var birot = 0
var direction = 1
var GatlingGun_Timer = 0
var GatlingGun_Tempo = 0
var GatlingGun_Modulo = 6
var vecteur_bullet_x = 15
var vecteur_bullet_y = 0
var linear_velocity_x = 800
var linear_velocity_y = -100

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

var bullet = preload("res://bullet1.tscn")
var fatality_hud = preload("res://fatality.tscn")
var floor_h_velocity = 0.0
var node_path_ammo = "/root/stage/HUD/Control/AmmoPlayer1"
var player

var move_left_analog
var move_right_analog
var move_up_analog
var move_down_analog

func analog_force_change(inForce, inAnalog):
	if (inForce.x < 0):
		move_left_analog = true
		move_right_analog = false
	elif (inForce.x > 0):
		move_left_analog = false
		move_right_analog = true
	else:
		move_left_analog = false
		move_right_analog = false

	if (inForce.y < -0.5):
		move_down_analog = true
		move_up_analog = false
	elif (inForce.y > 0.5):
		move_down_analog = false
		move_up_analog = true
	else:
		move_down_analog = false
		move_up_analog = false

func _integrate_forces(s):
	if (Game.health_p1 > 0 and not Game.fatality_running):
		var lv = s.get_linear_velocity()
		var step = s.get_step()

		var new_anim = anim
		var new_siding_left = siding_left

		# Get the controls
		var move_left = Input.is_action_pressed("move_left_p1")
		if (move_left_analog):
			move_left = move_left_analog
		var move_right = Input.is_action_pressed("move_right_p1")
		if (move_right_analog):
			move_right = move_right_analog
		var jump = Input.is_action_pressed("jump_p1")
		if (move_up_analog):
			jump = move_up_analog
		var crouch = Input.is_action_pressed("crouch_p1")
		if (move_down_analog):
			crouch = move_down_analog
		var shoot = Input.is_action_pressed("shoot_p1")

		if (get_node(node_path_ammo).get_node("ReloadingPlayer1").is_visible()):
			jump = false

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

		# Ramassage des darts
		for body in get_colliding_bodies():
			if (body.has_method("_on_bullet_body_enter_shape") and body.is_pickable()):
				body.queue_free()
				if (Game.ammo_p1 < Game.SHOOT_MAX):
					Game.ammo_p1 += 1
					var node_ammo = node_path_ammo + "/AmmoSprite" + str(Game.ammo_p1)
					get_node(node_ammo).show()

		# A good idea when impementing characters of all kinds,
		# compensates for physics imprecission, as well as human reaction delay.
		if (shoot and not shooting and Game.round_started) || (Game.gatlinggun_p1):
			if (! get_node("RayCastKick").is_colliding()):
				if (Game.gatlinggun_p1):
					crouch = null
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
	
				if (siding_left):
					birot = 180
				else:
					birot = 0
	
				var modulo = GatlingGun_Tempo % GatlingGun_Modulo
				if(modulo == 0 and not Game.fatality_ready and (Game.ammo_p1 > 0 or Game.gatlinggun_p1)):
					if (not Game.gatlinggun_p1):
						Game.ammo_p1 -= 1
						var node_ammo = node_path_ammo + "/AmmoSprite" + str(Game.ammo_p1+1)
						get_node(node_ammo).hide()
						if (Game.ammo_p1 == 0):
							get_node("Reloading_Timer").start()
							get_node(node_path_ammo).get_node("ReloadingPlayer1").show()
					var bi = bullet.instance()
					var pos = get_pos() + Vector2(vecteur_bullet_x*direction, vecteur_bullet_y) + get_node("bullet_shoot").get_pos()*Vector2(direction, -6.0)
					bi.set_pos(pos)
					get_parent().add_child(bi)
					bi.get_node("Sprite").set_rotd(birot)
					bi.set_linear_velocity(Vector2(linear_velocity_x*direction, linear_velocity_y))
				elif (Game.fatality_ready and not Game.fatality_executed and found_floor):
					Game.fatality_executed = true
					Game.fatality_running = true
	
				if(Game.ultimate_p1 >= Game.ultimate_limit and not Game.ultimate_running_p1):
					Game.ultimate_running_p1 = true
					get_node("Ultimate_Timer").start()
			else:
				if (!get_node("anim").get_current_animation() == "kick"):
					shoot_time = 0
					if (get_node("RayCastKick").get_collider().has_method("damage") and Game.health_p2 > 0):
						get_node("RayCastKick").get_collider().damage(Game.bullet_damage)
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
				new_siding_left = true
				direction = -1
			elif (lv.x > 0 and move_right):
				new_siding_left = false
				direction = 1
			if (jumping):
				new_anim = "jumping"
			elif (abs(lv.x) < 0.1):
				if (shoot_time < MAX_SHOOT_POSE_TIME):
					if (! get_node("RayCastKick").is_colliding()):
						new_anim = "idle_weapon"
					else:
						new_anim = "kick"
				else:
					new_anim = "idle"
			else:
				if (shoot_time < MAX_SHOOT_POSE_TIME):
					if (! get_node("RayCastKick").is_colliding()):
						new_anim = "run_weapon"
					else:
						new_anim = "kick"
				else:
					new_anim = "run"
			# Check crouch
			if (Game.ammo_p1 == 0):
				new_anim = "reloading"
				get_node("CollisionPolygon2D").set_scale(Vector2(2*direction, 0.8))
				get_node("CollisionPolygon2D").set_pos(Vector2(15*direction, 10))
				lv.x = 0
			elif (crouch):
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
					if (! get_node("RayCastKick").is_colliding()):
						new_anim = "jumping_weapon"
					else:
						new_anim = "kick"
				else:
					new_anim = "jumping"
			else:
				if (shoot_time < MAX_SHOOT_POSE_TIME):
					if (! get_node("RayCastKick").is_colliding()):
						new_anim = "falling_weapon"
					else:
						new_anim = "kick"
				else:
					new_anim = "falling"
				vecteur_bullet_y = 15

		# Update siding
		if (new_siding_left != siding_left):
			get_node("AnimatedSprite").set_scale(Vector2(0.5*direction, 0.5))
			get_node("RayCastKick").set_pos(Vector2(get_node("RayCastKick").get_pos().x*(-1), get_node("RayCastKick").get_pos().y))
			get_node("RayCastKick").set_cast_to(Vector2(get_node("RayCastKick").get_cast_to().x*(-1), get_node("RayCastKick").get_cast_to().y))
			siding_left = new_siding_left

		if (Game.gatlinggun_p1):
			new_anim = "gatlinggun"
			get_node("AnimatedSprite/Sparks").show()
			get_node("AnimatedSprite/Smoke").set_emitting(true)
			get_node("AnimatedSprite/Smoke").show()
			if (on_floor):
				lv.x -= direction*10
		else:
			get_node("AnimatedSprite/Sparks").hide()
			get_node("AnimatedSprite/Smoke").hide()

		# Change animation
		if (new_anim != anim):
			anim = new_anim
			get_node("anim").play(anim)

		shooting = shoot

		# Apply floor velocity
		if (found_floor):
			floor_h_velocity = s.get_contact_collider_velocity_at_pos(floor_index).x
			lv.x += floor_h_velocity

		# Finally, apply gravity and set back the linear velocity
		lv += s.get_total_gravity()*step
		s.set_linear_velocity(lv)
	elif (Game.fatality_running):
		s.set_linear_velocity(Vector2(0,0))


func _ready():
	player = ResourceLoader.load("res://player1.tscn")
	set_fixed_process(true)
	set_process_input(true)


func _fixed_process(delta):
	get_node("/root/stage/HUD/Control/HealthPlayer1").set_value(Game.health_p1)
	get_node("/root/stage/HUD/Control/UltimatePlayer1").set_value(Game.ultimate_p1)
	if (Game.health_p1 > 0):
		if (Game.health_p1 > Game.health_limit ):
			Game.health_p1 = Game.health_limit
		else:
			Game.health_p1 += delta * 2

		if (Game.health_p2 > 0 and not Game.gatlinggun_p1):
			Game.ultimate_p1 += delta * 5

		if (Game.gatlinggun_p1 and GatlingGun_Timer < 3):
			GatlingGun_Timer += delta
			WALK_MAX_VELOCITY = 1
			JUMP_VELOCITY = 230
		else:
			Game.gatlinggun_p1 = false
			WALK_MAX_VELOCITY = 200
			JUMP_VELOCITY = 460
	else:
		Game.fatality_timer += delta
		get_node(".").set_sleeping(true)
		if (Game.fatality_timer > 5 ):
			Game.fatality_ready = false
			die_p1()
			Game.defeat_p1 = true
		else:
			Game.fatality_ready = true


func damage(dmg):
	Game.health_p1 -= dmg
	#Fatality
	if (Game.health_p1 <= 0 and not Game.defeat_p1):
		get_parent().add_child(fatality_hud.instance())
		if (not Game.fatality_executed):
			get_node("anim").play("fatality")
	elif (Game.health_p1 > 0):
		get_node("Damage").play("Damage")


func die_p1():
	if (not Game.defeat_p1):
		Game.number_victory_p2 += 1
	if (not Game.fatality_executed):
		get_node("anim").play("defeat")
		get_node("CollisionPolygon2D").set_scale(Vector2(2*direction, 0.7))
		get_node("CollisionPolygon2D").set_pos(Vector2(5*direction, 20))


func _on_Reloading_Timer_timeout():
	get_node("Reloading_Timer").stop()
	get_node(node_path_ammo).get_node("ReloadingPlayer1").hide()
	Game.ammo_p1 = Game.SHOOT_MAX
	for node_index in range(Game.SHOOT_MAX):
		node_index += 1
		var node_ammo = node_path_ammo + "/AmmoSprite" + str(node_index)
		get_node(node_ammo).show()


func _on_Ultimate_Timer_timeout():
	Game.ultimate_p1 = 0
	Game.ultimate_running_p1 = false
