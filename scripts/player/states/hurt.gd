extends "motion.gd"

func enter(msg := {}):
	owner.playRandomAnim(["Hurt0"])
	owner.startGracePeriod()
	owner.canInput = false
	
	if !owner.flashing:
		owner.velocity = Vector2.ZERO
		owner.velocity -= Vector2(owner.currentBump, abs(owner.currentBump) * 2)
		owner.health -= owner.currentDamage
		
func update(delta):
	owner.animspeedAsVelocity()
	
	if owner.health <= 0:
			owner.kill()
