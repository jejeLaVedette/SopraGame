extends Node

onready var hud_scene = preload("res://Hud/main.tscn")

# Game stats (maximal)
const HEALTH_MAX = 100.0
const ARMOR_MAX = 100.0
const SHOOT_MAX = 3
onready var armor = 0.0
onready var ammo = 4
onready var health_limit = 100
onready var ultimate_limit = 100

# Level stats
onready var timer = 0
onready var munitions = 0
onready var munitions_total = 0
onready var round_max = 3
onready var round_current = 1
onready var spawn_gatlinggun = false
onready var gatlinggun_p1 = false
onready var gatlinggun_p2 = false
onready var spawn_timer = randi()%12+2
onready var fatality_timer = 0

# Player stats
onready var number_victory_p1 = 0
onready var ultimate_p1 = 0
onready var health_p1 = 100
onready var number_victory_p2 = 0
onready var ultimate_p2 = 0
onready var health_p2 = 100


func _ready():
	print("OfficeFight [0.1.0]")
	var hud = hud_scene.instance()
	add_child(hud)