extends KinematicBody2D

signal playerDamaged(dm, bm)

export(Resource) var character

onready var health = character.health
onready var maxSpeed = character.maxSpeed
onready var acceleration = character.acceleration
onready var friction = character.friction
onready var airFriction = character.airFriction
onready var jumpStrength = character.jumpStrength
onready var timeJumpApex = character.timeJumpApex
onready var fallMultiplier = character.fallMultiplier
onready var dashStrength = character.dashStrength
onready var aimWeight = character.aimWeight

onready var headTextures = character.headTextures
onready var playerNumberTexture = character.playerNumberTexture

var velocity := Vector2()
var groundAngle = -1
var snap = true
var snapAngle := Vector2(0.0, Globals.MAX_FLOOR_ANGLE)

var gravity
var jumpForce

var weapon
var currentWeapon
var weaponIndex = 0

var currentDamage := 0
var currentBump := 0.0
var flashing := false

onready var stateMachine = $StateMachine
onready var animator = $Graphics/PlayerAnimator
onready var body = $Graphics/Body
onready var head = $Graphics/Body/Head
onready var legs = $Graphics/Body/Legs
onready var shadow = $Graphics/Shadow
onready var hitbox = $CollisionShape2D
onready var camera = $Camera

func _ready():
	Globals.set("player", self)
	$Graphics/PlayerNumber.texture = playerNumberTexture
	
	loadWeapon(weaponIndex)
	
func _physics_process(delta):
	if Input.is_action_just_pressed("wps_left"):
		switchWeapon(-1)
	if Input.is_action_just_pressed("wps_right"):
		switchWeapon(1)
	
	animspeedAsVelocity()
	moveAndSnap(delta)
	handleWeaponInput(delta)
	flashBehaviour()
	
	camera.offset = lerp(camera.offset, Vector2(1.0, 1.0), 0.1)
	
	var spaceState = get_world_2d().direct_space_state
	var result = spaceState.intersect_ray(global_position, global_position + Vector2(0.0, OS.get_screen_size().y), [self], collision_mask, true)
	
	if result:
		shadow.global_position = result.position
		
func animspeedAsVelocity():
	if velocity.x != 0:
		animator.playback_speed = velocity.x / maxSpeed
	else:
		animator.playback_speed = 1
	
func moveAndSnap(delta):
	gravity = (2 * jumpStrength) / pow(timeJumpApex, 2)
	jumpForce = gravity * timeJumpApex
	
	if is_on_ceiling():
		velocity.y = 0
		
	velocity.y += gravity * delta * (fallMultiplier if velocity.y > 0 else 1)
		
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		groundAngle = collision.normal.angle()
	
	if snap:
		snapAngle = Vector2(0.0, Globals.MAX_FLOOR_ANGLE)
	else:
		snapAngle = Vector2()
		
	velocity = move_and_slide_with_snap(velocity, snapAngle, Vector2(0, groundAngle), true)

func loadWeapon(weaponID):
	var inheritFireAngle = 0
	
	if weapon != null:
		inheritFireAngle = weapon.global_rotation
		weapon.queue_free()
		
	var wpsType = load(Globals.LoadJSON("res://data/json/weapons.json", weaponID)["file"])
	var wps = load(Globals.LoadJSON("res://data/json/weapons.json", weaponID)["type"])
	currentWeapon = wps
	weapon = currentWeapon.instance()
	weapon.type = wpsType
	weapon.global_rotation = inheritFireAngle
	weapon.armsPos = body
	add_child(weapon)
	
func switchWeapon(dir):
	weaponIndex += 1 * dir
	loadWeapon(weaponIndex)
	reinitializeVars()
	
func flashBehaviour():
	if flashing:
		visible = !visible
		
func getInputDirection() -> int:
	var inputDirection = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	return inputDirection
	
func handleWeaponInput(_delta):
	var weaponDirection = Vector2(
	int(Input.is_action_pressed("aim_right")) - int(Input.is_action_pressed("aim_left")),
	int(Input.is_action_pressed("aim_down")) - int(Input.is_action_pressed("aim_up")))

	# Variables para girar el arma
	var weaponRotation
	var currentWeaponSpriteRotation = weapon.global_rotation

	if weaponDirection != Vector2.ZERO:
		# Encuentra el angulo al que se esta apuntando
		weaponRotation = weaponDirection.angle()

		# Gira el arma para que este alineada para disparar
		weapon.RotateTo(weaponRotation)
		
		# Espeja el sprite del jugador para que no dispare hacia atras
		if weaponDirection.x == -1:
			FlipGraphics(true)
		elif weaponDirection.x == 1:
			FlipGraphics(false)
			
	else:
		head.texture = headTextures[1]

		# Gira el arma de acuerdo al sprite
		if body.flip_h:
			weaponRotation = PI
		else:
			weaponRotation = 0

	# Gira el arma y el sprite
	weapon.RotateTo(weaponRotation)
	weapon.global_rotation = currentWeaponSpriteRotation
	weapon.global_rotation = lerp_angle(currentWeaponSpriteRotation, weaponRotation, aimWeight)
	weapon.ChangeSprite(body.flip_h)

func FlipGraphics(flip):
	head.flip_h = flip
	body.flip_h = flip
	legs.flip_h = flip
	
func takeDamage(damage, bump = maxSpeed * -1 if body.flip_h else maxSpeed * 1):
	currentDamage = damage
	currentBump = bump
	emit_signal("playerDamaged")

func reinitializeVars():
	maxSpeed = character.maxSpeed
	acceleration = character.acceleration
	friction = character.friction
	airFriction = character.airFriction
	jumpStrength = character.jumpStrength
	timeJumpApex = character.timeJumpApex
	fallMultiplier = character.fallMultiplier
	dashStrength = character.dashStrength
	aimWeight = character.aimWeight
