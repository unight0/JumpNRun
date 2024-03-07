extends Area2D

@onready var spr = $AnimatedSprite2D
@onready var closer_clldr = $Closer/CollisionShape2D

var is_opening = false
var is_closed = true

func open():
	spr.play("opening")
	is_opening = true
	is_closed = false

func _process(_d):
	if is_opening:
		if not spr.is_playing():
			spr.play("open")
			closer_clldr.set_deferred("disabled", true)
