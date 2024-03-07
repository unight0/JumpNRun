extends Node2D

@export var player : CharacterBody2D
@export var money_counter : Label
@export var golden_key_img : TextureRect
@export var silver_key_img : TextureRect
@export var golden_key_cntr : Label
@export var silver_key_cntr : Label

@onready var audioplayer = $Player/AudioStreamPlayer2D
@onready var fader = $Fader

func _process(delta):
	money_counter.text = str(player.money)
	silver_key_img.visible = player.silver_keys > 0
	silver_key_cntr.visible = player.silver_keys > 1
	silver_key_cntr.text = str(player.silver_keys)
	golden_key_img.visible = player.golden_keys > 0
	golden_key_cntr.visible = player.golden_keys > 1
	golden_key_cntr.text = str(player.golden_keys)

func play_sound(res, pos=0):
	audioplayer.stream = load("res://" + res)
	audioplayer.play(pos)
	await get_tree().create_timer(0.3).timeout


func _on_menu_button_pressed():
	await play_sound("button.wav", 0.2)
	await SceneChange.fade_in(fader)
	SceneChange.change_scene("res://menu.tscn")
