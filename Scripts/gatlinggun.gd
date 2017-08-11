extends RigidBody2D


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_RigidBody2D_body_enter( body ):
	if (body.has_method("damage")):
		queue_free()
