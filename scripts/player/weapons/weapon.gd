extends Sprite

signal weapon_ammo_updated()

export(Resource) var type

onready var ammo = type.maxAmmo setget _setAmmo
onready var cooldownTimer = $Cooldown
onready var hands = [$MainHand, $SecHand]

var rotationTimer = 5.0
var cooldownIsOver = false

var anglePerDirection = TAU / 8
var angleIndex = 0

var currentPlayer

onready var muzzleFlash = preload("res://data/player/projectiles/muzzle_flash.tscn")

func _ready():
	if type.hasCooldown:
		_startCooldown()
	else:
		cooldownIsOver = true
	
	modulate = currentPlayer.graphics.modulate
	cooldownTimer.connect("timeout", self, "_cooldownTimeout")
	
func ChangeSprite(flip):
	var angleStep = stepify(global_rotation, anglePerDirection)
	angleStep = fposmod(angleStep, TAU)
	angleIndex = int(angleStep / anglePerDirection)
	
	scale.y = flip
	
func _setAmmo(value : int) -> void:
	ammo = value
	emit_signal("weapon_ammo_updated")
	
func _process(_delta):
	if type.canRotate:
		doRotation()
		
	_handleFiring()
	
func _handleFiring():
	match type.fireType:
		0:
			if Input.is_action_just_pressed("shoot" + currentPlayer.inputSuffix) and cooldownIsOver:
				fire()
		1:
			if Input.is_action_pressed("shoot" + currentPlayer.inputSuffix) and cooldownIsOver:
				fire()
	
func doRotation():
	var direction = Vector2(
		int(Input.get_action_strength("aim_right" + currentPlayer.inputSuffix)) - int(Input.get_action_strength("aim_left" + currentPlayer.inputSuffix)),
		int(Input.get_action_strength("aim_down" + currentPlayer.inputSuffix)) - int(Input.get_action_strength("aim_up" + currentPlayer.inputSuffix)))
		
	var desiredRotation
	
	if currentPlayer.isGrounded:
		if direction.y == 1:
			direction.y = 0
		
	if direction != Vector2.ZERO:
		desiredRotation = direction.angle()
	else:
		if currentPlayer.getFacingDirection() == 1:
			desiredRotation = 0
		else:
			desiredRotation = PI
		
	rotation = lerp_angle(rotation, desiredRotation, type.aimWeight)
	ChangeSprite(currentPlayer.getFacingDirection())
	
func fire():
	if ammo > 0:
		Audio.playSound(0)
		
		if type.displayFlash:
			var newFlash = muzzleFlash.instance()
			newFlash.position = position + type.projectileOffset.rotated(rotation)
			newFlash.global_rotation = global_rotation
			currentPlayer.add_child(newFlash)
			
		if type.hasCooldown:
			_startCooldown()
			
		var newProjectile = type.projectile.instance()
		newProjectile.add_to_group("PlayerProjectile")
		
		for c in newProjectile.get_children():
			c.add_to_group("PlayerProjectile")
			
		newProjectile.global_position = global_position + type.projectileOffset.rotated(rotation)
		newProjectile.global_rotation = global_rotation
		newProjectile.z_index = z_index - 16
		newProjectile.papa = currentPlayer
		get_tree().get_current_scene().add_child(newProjectile)
			
		if type.recoil > 0.0:
			currentPlayer.velocity -= Vector2(type.recoil, 0.0).rotated(global_rotation)
		
		self.ammo -= 1
	else:
		Audio.playSound(1, Audio, 1.0, 2.0)
	
func _startCooldown():
	cooldownIsOver = false
	cooldownTimer.wait_time = type.cooldown
	cooldownTimer.start()
	
func _cooldownTimeout():
	cooldownIsOver = true
