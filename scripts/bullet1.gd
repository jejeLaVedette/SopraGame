extends RigidBody2D

var isAlreadyColliding
var bodyEnnemi = false
var first_contact = true
var bullet_explode = preload("res://bullet_explode.tscn")
var time_explode = 0
var rotation = 150
var x = 0
var y = 600
var rotation_inverse = 0
var global_pos


func _ready():
	isAlreadyColliding = false
	set_fixed_process(true)


func _fixed_process(delta):
	time_explode += delta
	var direction = get_node(".").get_linear_velocity().x
	if(Game.ultimate_running_p1 and first_contact):
		if(time_explode > 0.48 and time_explode < 0.5):
			for i in range(3):
				if (direction < 0):
					rotation_inverse = 180
				rotation-=30
				var be = bullet_explode.instance()
				var pos = get_node(".").get_pos() + Vector2(x/20, y/20).rotated(deg2rad(rotation+rotation_inverse))
				be.set_pos(pos)
				get_parent().add_child(be)
				be.get_node("Sprite").set_rotd(rotation+270)
				be.set_linear_velocity(Vector2(x, y).rotated(deg2rad(rotation+rotation_inverse)))
				PS2D.body_add_collision_exception(be.get_rid(), get_rid())
			get_node(".").queue_free()
	PS2D.body_add_collision_exception(get_node("/root/stage/Ground/rooftop/Sideleft").get_rid(), get_rid())


func _on_bullet_body_enter_shape( body_id, body, body_shape, local_shape ):
	if (body.has_method("damage") and isAlreadyColliding == false):
		body.damage(Game.bullet_damage)
		if(Game.health_p2 > 0):
			Game.ultimate_p1 += 15
		bodyEnnemi = true


func _on_bullet_body_exit_shape( body_id, body, body_shape, local_shape ):
	isAlreadyColliding = true
	get_node(".").set_pickable(true)


func _on_Timer_timeout():
	if (Game.gatlinggun_p1):
		queue_free()
