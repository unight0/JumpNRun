extends AnimatableBody2D

@onready var anim_player = $AnimationPlayer

var used = false

func _on_area_2d_area_entered(area):
	if not used:
		anim_player.play("movement")
		used = true
