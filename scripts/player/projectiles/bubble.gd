extends Projectile

export (int) var maxBounces := 5

var bounces := 0 setget _setBounces

func _ready():
	boundaries = $Hitbox/Boundaries
	hitbox = $Hitbox
	sprite = $Bubbly
	
	initialize()
	
func setupSpeed():
	velocity = speed.rotated(rotation)
	velocity.y -= initialJump
	rotation = 0
	
func move(delta):
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		velocity = velocity.bounce(collision.normal)
		self.bounces += 1
		
func _setBounces(value : int):
	if bounces == maxBounces:
		kill()
		
	bounces = value
