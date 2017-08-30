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
onready var round_started = false
onready var spawn_timer_array = [0, 0]
onready var spawn_object_array = ["gatlinggun", "healthpack"]
onready var spawn_healthpack = false
onready var spawn_gatlinggun = false
onready var gatlinggun_p1 = false
onready var gatlinggun_p2 = false
onready var fatality_timer = 0
onready var defeat_p1 = false
onready var defeat_p2 = false

# Player stats
onready var number_victory_p1 = 0
onready var ultimate_p1 = 0
onready var health_p1 = 100
onready var number_victory_p2 = 0
onready var ultimate_p2 = 0
onready var health_p2 = 100

# Weapon stats
onready var bullet_damage = 40
onready var bullet_ulti_damage = 20

func _ready():
	print("OfficeFight [0.1.0]")
	randomize()
	for i in range(0, spawn_timer_array.size()):
		spawn_timer_array[i] = randi()%12+2

	var hud = hud_scene.instance()
	add_child(hud)