extends Node2D

signal level_initialized
signal level_started

onready var musicPlayer = preload("res://streams/music_player.tscn")
onready var debugOverlay = preload("res://debug/debug_overlay.tscn").instance()

export (NodePath) var startPosition
export (int) var backgroundID
export (int) var musicID

onready var startPos = get_node(startPosition).position

func _init():
	Objects.currentWorld = self
	
func _ready():
	var startTimer = Objects.spawn(25)
	startTimer.connect("level_start", self, "start")
	Audio.fade()
	
	Renderer.fade("out")
	Renderer.backgroundSetup(backgroundID)
	Objects.spawn(22)
	Objects.spawnPlayer(0, startPos)
	
	emit_signal("level_initialized")

func start():
	emit_signal("level_started")
	Audio.musicSetup(musicID)
