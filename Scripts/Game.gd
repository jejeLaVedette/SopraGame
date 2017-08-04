extends Node

onready var hud_scene = preload("res://Hud/main.tscn")

# Consts for status
const STATUS_ALIVE = 0
const STATUS_DEAD = 1

# Game stats (maximal)
# TODO: Use them in other scripts
const HEALTH_MAX = 100.0
const ARMOR_MAX = 100.0
const SHOOT_MAX = 3

# Game stats
onready var healthPlayer1 = 100.0
onready var healthPlayer2 = 100.0
onready var armor = 0.0
onready var ammo = 4

# Level stats
onready var timer = 0
onready var munitions = 0
onready var munitions_total = 0
onready var round_max = 3
onready var round_current = 1

# Player stats
onready var number_player1_victory = 0
onready var number_player2_victory = 0

# For menus and respawning
onready var level_to_play = 1

onready var status = STATUS_ALIVE

func _ready():
	print("OfficeFight [0.1.0]")
	var hud = hud_scene.instance()
	add_child(hud)