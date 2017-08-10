extends RigidBody2D

var isAlreadyColliding
var bodyEnnemi = false


func _ready():
	isAlreadyColliding = false


func _on_bullet_body_enter_shape( body_id, body, body_shape, local_shape ):
	if (body.has_method("damage") and isAlreadyColliding == false):
			body.damage(40)
			bodyEnnemi = true
			add_collision_exception_with(body)


func _on_bullet_body_exit_shape( body_id, body, body_shape, local_shape ):
	isAlreadyColliding = true;
