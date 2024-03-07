extends Control

@onready var audioplayer = $AudioStreamPlayer2D
@onready var anim_player = $CanvasModulate/AnimationPlayer

func play_sound(res, pos=0):
	audioplayer.stream = load("res://" + res)
	audioplayer.play(pos)
	
func _on_level_1_pressed():
	play_sound("button.wav", 0.2)
	await SceneChange.fade_in(anim_player)
	SceneChange.change_scene("res://level_1.tscn")


func _on_level_2_pressed():
	play_sound("button.wav", 0.2)
	await SceneChange.fade_in(anim_player)
	SceneChange.change_scene("res://level_2.tscn")


func _on_level_3_pressed():
	play_sound("button.wav", 0.2)
	await SceneChange.fade_in(anim_player)
	SceneChange.change_scene("res://level_3.tscn")
