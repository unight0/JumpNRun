extends Area2D

@export var safe_point_marker : Marker2D

@onready var safe_point = safe_point_marker.position

func _on_body_entered(body):
	# MAKE CHANGES LATER
	if body.is_in_group("player"):
		body.position = safe_point
		body.velocity = Vector2.ZERO
