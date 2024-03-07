extends Control

@onready var audioplayer = $AudioStreamPlayer2D
@onready var anim_player = $AnimationPlayer

func play_sound(res, pos=0):
	audioplayer.stream = load("res://" + res)
	audioplayer.play(pos)
	await SceneChange.fade_in(anim_player)

func _on_exit_pressed():
	await play_sound("button.wav", 0.2)
	get_tree().quit()

func _on_play_pressed():
	await play_sound("button.wav", 0.2)
	SceneChange.change_scene("res://level_choice.tscn")
