
extends RigidBody2D

# Member variables
var anim = ""
var siding_left = false
var jumping = false
var stopping_jump = false
var shooting = false
var birot = 0
onready var health = 100

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

var bullet = preload("res://bullet.tscn")

var floor_h_velocity = 0.0
var player


func _integrate_forces(s):
	var lv = s.get_linear_velocity()
	var step = s.get_step()
	
	var new_anim = anim
	var new_siding_left = siding_left
	
	# Get the controls
	var move_left = Input.is_action_pressed("move_left2")
	var move_right = Input.is_action_pressed("move_right2")
	var jump = Input.is_action_pressed("jump2")
	var shoot = Input.is_action_pressed("shoot2")
	var spawn = Input.is_action_pressed("spawn2")
	var crouch = Input.is_action_pressed("crouch2")
	
	if spawn:
		var e = player.instance()
		var p = get_pos()
		p.y = p.y - 100
		e.set_pos(p)
		get_parent().add_child(e)
	
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
	if (shoot and not shooting):
		shoot_time = 0
		var bi = bullet.instance()
		var ss
		if (siding_left):
			ss = -1.0
			birot = 180
		else:
			ss = 1.0
			birot = 0
		var pos = get_pos() + get_node("bullet_shoot").get_pos()*Vector2(ss, 1.0)
		
		bi.set_pos(pos)
		get_parent().add_child(bi)
		bi.get_node("sprite").set_rotd(birot)
		bi.set_linear_velocity(Vector2(800.0*ss, -200))
		PS2D.body_add_collision_exception(bi.get_rid(), get_rid()) # Make bullet and this not collide
	else:
		shoot_time += step
	
	if (found_floor):
		airborne_time = 0.0
	else:
		airborne_time += step # Time it spent in the air
	
	var on_floor = airborne_time < MAX_FLOOR_AIRBORNE_TIME

	# Process jump
	if (jumping):
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
		elif (lv.x > 0 and move_right):
			new_siding_left = false
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
			get_node("CollisionPolygon2D").set_pos(Vector2(0, 20))
		else:
			get_node("CollisionPolygon2D").set_pos(Vector2(0, 0))
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
			get_node("sprite").set_scale(Vector2(-1, 1))
		else:
			get_node("sprite").set_scale(Vector2(1, 1))
		
		siding_left = new_siding_left
	
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
	player = ResourceLoader.load("res://player.tscn")
	set_fixed_process(true)
	set_process_input(true)

func _fixed_process(delta):
	get_node("/root/Game/HUD/Control/HealthPlayer1").set_value(health)
	health += delta * 2

func damage(dmg):
	print("damage player1")
	health -= dmg
	if health <= 0:
		die()

func die():
	queue_free()