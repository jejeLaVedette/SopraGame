extends Node

# Game stats (maximal)
const HEALTH_MAX = 100.0
const ARMOR_MAX = 100.0
const SHOOT_MAX = 5
onready var armor = 0.0
onready var ammo_p1 = 5
onready var ammo_p2 = 5
onready var health_limit = 100
onready var ultimate_limit = 100

# Level stats
onready var timer = 0
onready var munitions = 0
onready var munitions_total = 0
onready var round_max = 3
onready var round_current = 1
onready var round_started = false
onready var spawn_timer_array = [0, 0]
onready var spawn_object_array = ["gatlinggun", "healthpack"]
onready var spawn_healthpack = false
onready var spawn_gatlinggun = false
onready var gatlinggun_p1 = false
onready var gatlinggun_p2 = false
onready var fatality_timer = 0
onready var fatality_ready = false
onready var fatality_executed = false
onready var fatality_running = false
onready var defeat_p1 = false
onready var defeat_p2 = false
onready var drone_straffing = false
onready var drone_timer = 0

# Player stats
onready var number_victory_p1 = 0
onready var ultimate_p1 = 0
onready var ultimate_running_p1 = false
onready var health_p1 = 100
onready var number_victory_p2 = 0
onready var ultimate_p2 = 0
onready var ultimate_running_p2 = false
onready var health_p2 = 100

# Weapon stats
onready var bullet_damage = 40
onready var bullet_ulti_damage = 20

# Menu
onready var versus_player = false
onready var versus_bot = true

# Loading
var loader
var wait_frames
var time_max = 100 # msec
var current_scene


func _ready():
	print("OfficeFight [0.1.0]")
	randomize()
	# Remplissage du tableau des objets à spawn par des temps aléatoires
	for i in range(0, spawn_timer_array.size()):
		spawn_timer_array[i] = randi()%12+2
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)


func goto_scene(path): # game requests to switch to this scene
	loader = ResourceLoader.load_interactive(path)
	if loader == null: # check for errors
		show_error()
		return
	set_process(true)
	current_scene.queue_free() # get rid of the old scene
	wait_frames = 1


func _process(time):
	if loader == null:
		# no need to process anymore
		set_process(false)
		return

	if wait_frames > 0: # wait for frames to let the "loading" animation to show up
		wait_frames -= 1
		return

	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + time_max: # use "time_max" to control how much time we block this thread
		# poll loader
		var err = loader.poll()

		if (err == ERR_FILE_EOF): # load finished
			var resource = loader.get_resource()
			loader = null
			set_new_scene(resource)
			break
		elif (err == OK):
			update_progress()
		else: # error during loading
			show_error()
			loader = null
			break


func update_progress():
	var progress = float(loader.get_stage()) / loader.get_stage_count()
	# update progress bar
	get_node("LoadingProgress").set_unit_value(progress)


func set_new_scene(scene_resource):
	current_scene = scene_resource.instance()
	get_node("/root").add_child(current_scene)
	get_tree().set_current_scene(current_scene)
