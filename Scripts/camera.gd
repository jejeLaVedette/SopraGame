extends Camera2D

# variable pour récupérer le player1
var p1
# variable pour récupérer le player2
var p2
#indice de zoom
var zoom_factor=1

func _ready():
	# on recup les player1 et 2
	p1 = get_node("/root/stage/Player1")
	p2 = get_node("/root/stage/Player2")
	set_fixed_process(true)

func _fixed_process(delta):
	# si les deux joueurs sont présents, alors on bouge la caméra et le zoom en fonction de leur position
	var wr1 = weakref(p1);
	var wr2 = weakref(p2);
	if (wr1.get_ref() and wr2.get_ref()):
		var newpos = (p1.get_global_pos() + p2.get_global_pos()) * 0.5
		set_global_pos(newpos)
		var distance = p1.get_global_pos().distance_to(p2.get_global_pos()) * 2
		var zoom_factor = distance * 0.005
		var zoom = Vector2(1,1) * zoom_factor / 4
		if (Vector2(1,1) < zoom):
			set_zoom(zoom)
	elif (wr1.get_ref()):
		var newpos = (p1.get_global_pos())
		set_global_pos(newpos)
		set_zoom(Vector2(1,1))
	elif (wr2.get_ref()):
		var newpos = (p2.get_global_pos())
		set_global_pos(newpos)
		set_zoom(Vector2(1,1))
