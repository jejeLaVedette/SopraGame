extends RigidBody2D


func _on_GatlingGun_body_enter( body ):
	get_node(".").set_gravity_scale(1)
	get_node("Parachute").set_opacity(0)
	if (body.has_method("die_p1")):
		Game.gatlinggun_p1 = true
		queue_free()
	elif (body.has_method("die_p2")):
		Game.gatlinggun_p2 = true
		queue_free()
