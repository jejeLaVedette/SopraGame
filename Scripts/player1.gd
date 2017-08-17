extends RigidBody2D

# Member variables
var anim = ""
var siding_left = false
var jumping = false
var stopping_jump = false
var shooting = false
var birot = 0
var direction = 1
var hauteur_tir = 0
var GatlingGun_Timer = 0
var ultimate_timer_p1 = 0

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

var floor_h_velocity = 0.0
var player


func _integrate_forces(s):
	var lv = s.get_linear_velocity()
	var step = s.get_step()
	
	var new_anim = anim
	var new_siding_left = siding_left
	
	# Get the controls
	var move_left = Input.is_action_pressed("move_left_p1")
	var move_right = Input.is_action_pressed("move_right_p1")
	var jump = Input.is_action_pressed("jump_p1")
	var shoot = Input.is_action_pressed("shoot_p1")
	var special = Input.is_action_pressed("special_p1")
	var crouch = Input.is_action_pressed("crouch_p1")

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
	
	# A good idea when impementing characters of all kinds,
	# compensates for physics imprecission, as well as human reaction delay.
	if (shoot and not shooting) || (Game.gatlinggun_p1):
		if (Game.gatlinggun_p1):
			crouch = null
			jump = null
			shoot = null
			hauteur_tir = 13
		else:
			shoot_time = 0
		var bi = bullet.instance()
		var ss
		if (siding_left):
			ss = -1.0
			birot = 180
		else:
			ss = 1.0
			birot = 0
		var pos = get_pos() + Vector2(15*direction, hauteur_tir) + get_node("bullet_shoot").get_pos()*Vector2(ss, -6.0)
		
		bi.set_pos(pos)
		get_parent().add_child(bi)
		bi.get_node("sprite").set_rotd(birot)
		bi.set_linear_velocity(Vector2(800.0*ss, -100))
		PS2D.body_add_collision_exception(bi.get_rid(), get_rid()) # Make bullet and this not collide
		if (get_parent().has_node("Player2") and not Game.gatlinggun_p1):
			Game.ultimate_p1 += 5
		if(Game.ultimate_p1 >= Game.ultimate_limit):
			ultimate_timer_p1 += 1
			if(ultimate_timer_p1 > 4):
				Game.ultimate_p1 = 0
				ultimate_timer_p1 = 0
	else:
		shoot_time += step
	
	if (found_floor):
		airborne_time = 0.0
	else:
		airborne_time += step # Time it spent in the air
	
	var on_floor = airborne_time < MAX_FLOOR_AIRBORNE_TIME

	# Process jump
	if (jumping):
		hauteur_tir = 15
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
			hauteur_tir = 30
			lv.x = 0
		else:
			get_node("CollisionPolygon2D").set_scale(Vector2(direction, 1))
			get_node("CollisionPolygon2D").set_pos(Vector2(0, 0))
			hauteur_tir = 0
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
	
	# Update siding
	if (new_siding_left != siding_left):
		if (new_siding_left):
			get_node("AnimatedSprite").set_scale(Vector2(0.2*direction, 0.2))
			get_node("GatlingGun").set_scale(Vector2(0.12*direction, 0.12))
			get_node("GatlingGun").set_pos(Vector2(18*direction, -15))
		else:
			get_node("AnimatedSprite").set_scale(Vector2(0.2*direction, 0.2))
			get_node("GatlingGun").set_scale(Vector2(0.12*direction, 0.12))
			get_node("GatlingGun").set_pos(Vector2(18*direction, -15))
		siding_left = new_siding_left

	if (Game.gatlinggun_p1):
		new_anim = "idle"

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


func _ready():
	player = ResourceLoader.load("res://player1.tscn")
	set_fixed_process(true)
	set_process_input(true)


func _fixed_process(delta):
	get_node("/root/Game/HUD/Control/HealthPlayer1").set_value(Game.health_p1)
	get_node("/root/Game/HUD/Control/UltimatePlayer1").set_value(Game.ultimate_p1)
	Game.health_p1 += delta * 2
	if (get_parent().has_node("Player2") and not Game.gatlinggun_p1):
		Game.ultimate_p1 += delta*5
	if (Game.gatlinggun_p1 and GatlingGun_Timer < 3):
		GatlingGun_Timer += delta
		WALK_MAX_VELOCITY = 1
		get_node("GatlingGun").set_opacity(1)
	else:
		Game.gatlinggun_p1 = false
		WALK_MAX_VELOCITY = 200
		get_node("GatlingGun").set_opacity(0)


func damage(dmg):
	Game.health_p1 -= dmg
	if Game.health_p1 <= 0:
		die_p1()


func die_p1():
	Game.number_victory_p2 += 1
	queue_free()
