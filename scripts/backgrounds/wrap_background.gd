extends TextureRect

var offsetLimit = texture.get_size()
export (Vector2) var startingPos = Vector2(-512, -424)
export (bool) var moveHorizontally = true
export (bool) var moveVertically = true
export (int) var speed = 1
export (int) var sizeMultiplier = 2

func _ready():
	rect_size = rect_size + (offsetLimit * sizeMultiplier)
	print(offsetLimit)
	
func _process(_delta):
	if moveHorizontally:
		rect_position.x -= speed
	
	if moveVertically:
		rect_position.y -= speed
		
	if sign(speed) == 1:
		if (abs(rect_position.x) >= offsetLimit.x):
			rect_position.x = 0
			
		if (abs(rect_position.y) >= offsetLimit.y):
			rect_position.y = 0
			
	if sign(speed) == -1:
		if (abs(rect_position.x) <= offsetLimit.x):
			rect_position.x = startingPos.x
			
		if (abs(rect_position.y) <= offsetLimit.y):
			rect_position.y = startingPos.y
