extends AnimatableBody2D

@onready var sprite = $AnimatedSprite2D

func _process(_d):
	sprite.flip_h = get_meta("flip_h")
