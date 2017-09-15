extends Node2D


var motion = Vector2(100, 0)
var cycle = 5
var accum = 0.0
var bullet = preload("res://bullet_explode.tscn")


func _ready():
	set_fixed_process(true)


func _fixed_process(delta):
	accum += delta*(1.0/cycle)*PI*2.0
	accum = fmod(accum, PI*2.0)
	var d = sin(accum)
	var xf = Matrix32()
	xf[2]= motion*d 
	get_node("Drone").set_transform(xf)
	get_node("Drone").set_scale(Vector2(0.05, 0.05))


func _on_TimerBullet_timeout():
	if (Game.drone_straffing and get_node("Drone").is_visible()):
		var rotation = 240
		var x = -1
		for i in range(3):
			var bullet_instance = bullet.instance()
			var pos = get_node("Drone").get_pos() + Vector2(x*20, 0)
			bullet_instance.set_pos(pos)
			get_parent().add_child(bullet_instance)
			bullet_instance.get_node("Sprite").set_rotd(rotation)
			bullet_instance.set_applied_force(Vector2(x, 1))
			rotation += 30
			x += 1
