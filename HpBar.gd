extends TextureProgressBar

@export var player : CharacterBody2D

func _ready():
	self.max_value = player.max_hp

func _process(_delta):
	self.value = player.hp
