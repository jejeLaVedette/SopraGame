extends RigidBody2D

var Angle=randi() % 10
var isAlreadyColliding
var bodyEnnemi = false

func _ready():
	isAlreadyColliding = false

func _on_bullet_body_enter_shape( body_id, body, body_shape, local_shape ):
#	set_linear_damp(Angle)
#	if (body.get_name()=="Player"):
#		if Game.munitions < Game.munitions_total:
#			Game.munitions += 1
#		get_node(".").queue_free()
	
	if body.has_method("damage") and isAlreadyColliding == false:
			body.damage(25)
			bodyEnnemi = true
			#On retire la colission
			add_collision_exception_with(body)

func _on_bullet_body_exit_shape( body_id, body, body_shape, local_shape ):
	isAlreadyColliding = true;
