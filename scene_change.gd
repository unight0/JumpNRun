extends Node

func fade_in(anim_player):
	anim_player.play("fade")
	await anim_player.animation_finished
	await get_tree().create_timer(0.3).timeout
	
# Doesn't work for some reason
func new_fade_in():
	var fader = load("res://fader.tscn")
	var fobj = fader.instantiate()
	var anim_player = fobj.get_node("AnimationPlayer")
	anim_player.play("fade_in")
	print(anim_player.is_playing())
	#await anim_player.animation_finished
	await get_tree().create_timer(0.5).timeout
	fobj.queue_free()

var changing_scene = false
@onready var timestamp = Time.get_ticks_msec()

func change_scene(scene_name):
	if Time.get_ticks_msec() - timestamp >= 1000:
		changing_scene = false
	if changing_scene:
		return
	get_tree().change_scene_to_file(scene_name)
	changing_scene = true
