extends RigidBody2D

var isAlreadyColliding
var bodyEnnemi = false


func _ready():
	isAlreadyColliding = false
	get_node("Particles2D").set_emitting(true)

func _on_bullet_body_enter_shape( body_id, body, body_shape, local_shape ):
	get_node("Particles2D").set_emitting(false)
	if (body.has_method("damage") and isAlreadyColliding == false):
			body.damage(Game.bullet_ulti_damage)
			bodyEnnemi = true
			add_collision_exception_with(body)


func _on_bullet_body_exit_shape( body_id, body, body_shape, local_shape ):
	isAlreadyColliding = true;


func _on_Timer_timeout():
	queue_free()
