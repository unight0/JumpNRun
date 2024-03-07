extends Camera2D

@export var player : Node2D
@export var action_distance = 32
@export var speed = 100

func _ready():
	zoom = Vector2(3,3)

func _process(delta):
	var distance = position.distance_to(player.position)
	if distance >= action_distance:
		var dir = position.direction_to(player.position)
		var coeff = distance/action_distance/1.5
		var velocity = dir * speed * coeff * delta
		position += velocity
	
