extends KinematicBody2D
class_name Kinematos

# warning-ignore:unused_signal
signal camera_shake_requested(mode, time, amp)
signal grounded_updated(isGrounded)
signal gravity_updated(doinGravity)

var canInput := false
var applyGravity := true setget _doGravity
var isGrounded := true

var inputSuffix := ""
export (float) var acceleration
export (float) var jumpForce
export (float) var jumpStrength
var lastGoodPosition := Vector2()
export (float) var maxSpeed
var velocity := Vector2()
export (float) var fallMultiplier = 1.0
export (float) var friction = 1.0
var snapVector = Vector2(0.0, Globals.MAX_FLOOR_ANGLE)
export (float) var timeJumpApex = 1.0

onready var mainSprite : Sprite
onready var animator : AnimationPlayer

func _physics_process(delta):
	groundCheck()
	doGravity(delta)
	mainMotion(delta)
	
func mainMotion(_delta):
	velocity.y = move_and_slide_with_snap(velocity, snapVector, Globals.UP, true).y
	
func doGravity(delta):
	var gravity
	gravity = (2 * jumpStrength) / pow(timeJumpApex, 2)
	
	jumpForce = gravity * timeJumpApex
	
	if applyGravity:
		velocity.y += gravity * delta * (fallMultiplier if velocity.y > 0 else 1)
	
func groundCheck():
	var wasGrounded = isGrounded
	isGrounded = is_on_floor()
	
	if wasGrounded == null || isGrounded != wasGrounded:
		emit_signal("grounded_updated", isGrounded)
		lastGoodPosition = position
	
func _doGravity(booly : bool) -> void:
	applyGravity = booly
	emit_signal("gravity_updated", applyGravity)
	
func checkPushables(vel = velocity.x):
	var isOnEnvironment = false
	var pushable
	
	for b in get_slide_count():
		var body = get_slide_collision(b).collider
		
		if body:
			if body.is_in_group("Pushable"):
				pushable = body
			elif body.is_in_group("Environment"):
				isOnEnvironment = true
			
	if isOnEnvironment && pushable:
		pushable.Push(vel)
		
func setCollisionBits(bitArray := [], booly := true):
	for bit in bitArray:
		set_collision_mask_bit(bit, booly)

func keepOnScreen(clampX := true, clampY := false, offset := Vector2()):
	var ctrans = get_canvas_transform()

	var minPos = -ctrans.get_origin() / ctrans.get_scale()

	var viewSize = get_viewport_rect().size / ctrans.get_scale()
	var maxPos = minPos + viewSize
	
	if clampX:
		global_position.x = clamp(global_position.x, minPos.x + offset.x, maxPos.x - offset.x)
	if clampY:
		global_position.y = clamp(global_position.y, minPos.y + offset.y, maxPos.y - offset.y)

func placeOutOfScreen(side := -1, offset := 128):
	var ctrans = get_canvas_transform()
	
	var minPos = -ctrans.get_origin() / ctrans.get_scale()
	
	var viewSize = get_viewport_rect().size / ctrans.get_scale()
	
	var maxPos = minPos + (viewSize / 2)
	
	global_position.x = (maxPos.x * side) + (offset * side)
	
func getStandingTile(feetPos, tileMap := Objects.currentWorld.tileMap):
	var curTilePos = tileMap.world_to_map(feetPos)
	var curTile = tileMap.get_cellv(Vector2(curTilePos.x, curTilePos.y + 1))
	
	return curTile
	
func getShaderParam(parameter : String):
	var material = self.get_material()
	return material.get_shader_param(parameter)
	
func setupProperties(res : Resource, pStart := 8, pEnd := 0):
	var resPCount = res.get_property_list().size()
	
	for v in range(pStart, resPCount if pEnd == 0 else pEnd):
		var curP = res.get_property_list()[v].name
		
		set(curP, res.get(curP))
	
func getInputDirection(suffix := inputSuffix) -> int:
	if canInput:
		var inputDirection = Input.get_action_strength("move_right" + suffix) - Input.get_action_strength("move_left" + suffix)
		
		if inputDirection:
			flipGraphics(inputDirection)
		
		return inputDirection
	else: return 0
	
func getFacingDirection(spr := mainSprite):
	var facingDirection = spr.scale.x
	return facingDirection
	
func animspeedAsVelocity():
	if getInputDirection():
		animator.playback_speed = velocity.x / maxSpeed
	else:
		animator.playback_speed = 1
	
func playRandomAnim(anims : Array):
	randomize()
	var animToPlay = randi() % anims.size()
	animator.play(anims[animToPlay])
	
func flipGraphics(facing, spr := mainSprite):
	spr.scale.x = facing
	
func move(speed := maxSpeed, direction := getInputDirection()):
	velocity.x = clamp(velocity.x + (acceleration * direction), -speed, speed)
	
func damp(damping := friction):
	velocity.x *= damping
