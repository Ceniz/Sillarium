extends Resource
class_name PlayerStats

export (int) var health = 10
export (float) var maxSpeed = 300.0
export (float) var acceleration = 75.0
export (float) var friction = 300.0
export (float) var airFriction = 5.0
export (float) var jumpStrength = 200.0
export (float) var timeJumpApex = 0.4
export (float) var fallMultiplier = 1.5
export (float) var dashStrength = 1000.0
export (float, 0, 1) var aimWeight = 0.5

export (Array, AtlasTexture) var headTextures
export (Texture) var playerNumberTexture
