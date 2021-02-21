extends "res://data/ui/menu/button.gd"

enum {SWITCH, INPUT, VALUE}

var type = VALUE

var category
var key
var val

var font
var multiplier

func _ready():
	modulate.a = 0.0
	theme = preload("res://sprites/ui/menu/main_theme.tres")
	updateText()
	
func _process(_delta):
	if modulate.a < 1.0:
		modulate.a += multiplier
	else:
		modulate.a = 1.0
	
func buttonPress():
	match type:
		SWITCH:
			print(str(key))
			val = !val
			Settings.setSetting(category, key, val)
			Settings.saveSettings()
			
			if key == "display_backgrounds":
				Renderer.backgroundSetup(Objects.currentWorld.backgroundID)
			if key == "fullscreen":
				Renderer.toggleFS()
			if key == "mute_audio":
				Audio.musicSetup(Objects.currentWorld.musicID)
		INPUT:
			Objects.currentWorld.toggleButtons(1)
			var binder = preload("res://data/ui/menu/options_menu/key_binder.tscn")
			var newBinder = binder.instance()
			
			newBinder.daddyButton = self
			newBinder.control = str(key).to_upper()
			newBinder.key = OS.get_scancode_string(int(val)).to_upper()
			get_tree().get_root().add_child(newBinder)
			
	updateText()
				
func updateText():
	val = Settings._configFile.get_value(category,key)
	var confiText
	
	if str(val) == "True":
		type = SWITCH
		confiText = "YES"
		text = ("%s: %s" % [key, confiText]).to_upper()
	elif str(val) == "False":
		type = SWITCH
		confiText = "NO"
		text = ("%s: %s" % [key, confiText]).to_upper()
	else:
		type = INPUT
		text = ("%s: %s" % [key, OS.get_scancode_string(int(val))]).to_upper()
		
	text = text.replace("_", " ")
	add_font_override("font", font)
