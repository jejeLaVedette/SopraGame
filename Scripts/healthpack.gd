extends RigidBody2D


func _on_HealthPack_body_enter( body ):
	get_node(".").set_gravity_scale(1)
	get_node(".").set_sleeping(true)
	get_node("Parachute").set_opacity(0)
	if (body.has_method("die_p1") and Game.health_p1 < Game.health_limit):
		Game.health_p1 += 50
		if (Game.health_p1 > Game.health_limit):
			Game.health_p1 = Game.health_limit
		queue_free()
	elif (body.has_method("die_p2") and Game.health_p2 < Game.health_limit):
		Game.health_p2 += 50
		if (Game.health_p2 > Game.health_limit):
			Game.health_p2 = Game.health_limit
		queue_free()
