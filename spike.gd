extends StaticBody2D

@export var safe_point_marker : Marker2D

@onready var safe_point = safe_point_marker.position

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		body.position = safe_point
		body.velocity.y = 0
