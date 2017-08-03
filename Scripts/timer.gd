extends Label

var timer = 0
var rounded_timer = 0

func _ready():
	set_process(true)

func _process(delta):
	timer += delta
	rounded_timer = round(timer)
	set_text(str(rounded_timer))