extends RigidBody2D

var isAlreadyColliding


func _ready():
	isAlreadyColliding = false
	get_node("Sprite/Particles2D").set_emitting(true)
	set_fixed_process(true)


func _fixed_process(delta):
	PS2D.body_add_collision_exception(get_node("/root/stage/Ground/rooftop/Sideleft").get_rid(), get_rid())


func _on_bullet_body_enter_shape( body_id, body, body_shape, local_shape ):
	get_node("Sprite/Particles2D").set_emitting(false)
	if (body.has_method("damage") and isAlreadyColliding == false):
		body.damage(Game.bullet_ulti_damage)
		add_collision_exception_with(body)


func _on_bullet_body_exit_shape( body_id, body, body_shape, local_shape ):
	isAlreadyColliding = true;


func _on_Timer_timeout():
	queue_free()
