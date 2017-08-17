extends RigidBody2D

var isAlreadyColliding
var bodyEnnemi = false
var bullet_explode = preload("res://bullet_explode.tscn")
var time_explode = 0
var rotation = 0
var x = 0
var y = 400


func _ready():
	isAlreadyColliding = false
	set_fixed_process(true)


func _fixed_process(delta):
	time_explode += delta
	if(Game.ultimate_p1 >= Game.ultimate_limit):
		if(time_explode > 0.48 and time_explode < 0.5):
			for i in range(8):
				rotation-=45
				var be = bullet_explode.instance()
				var pos = get_node(".").get_pos() + Vector2(x/20, y/20).rotated(deg2rad(rotation))
				be.set_pos(pos)
				get_parent().add_child(be)
				be.set_linear_velocity(Vector2(x, y).rotated(deg2rad(rotation)))
				be.get_node("sprite").set_rotd(rotation+270)
				PS2D.body_add_collision_exception(be.get_rid(), get_rid())
			get_node(".").queue_free()


func _on_bullet_body_enter_shape( body_id, body, body_shape, local_shape ):
#	if (body.get_name()=="Player"):
#		if Game.munitions < Game.munitions_total:
#			Game.munitions += 1
#		get_node(".").queue_free()
	if (body.has_method("damage") and isAlreadyColliding == false):
		body.damage(40)
		Game.ultimate_p1 += 15
		bodyEnnemi = true
		#On retire la colission
		add_collision_exception_with(body)


func _on_bullet_body_exit_shape( body_id, body, body_shape, local_shape ):
	isAlreadyColliding = true;


func _on_Timer_timeout():
	if (Game.gatlinggun_p1):
		queue_free()
