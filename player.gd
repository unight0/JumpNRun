extends CharacterBody2D

# Acceleration of free fall
# Adjusted a bit
const G = 9.8*2

@export var speed = 100
@export var acc = speed/1.6
@export var friction_coeff = 0.2

@export var max_press_length = 0.1
@export var jump_speed = 16*25

@export var climbing_speed = 16*12
@export var descending_speed = 16*1

@export var max_dashing_time = .3
@export var dash_speed_coeff = 3
@export var dash_cooldown_time = .5

@export var jump_forgiveness_time = .2

@export var max_hp = 100

@export var safe_point_marker : Marker2D

@onready var safe_point = safe_point_marker.position
@onready var sprite = $AnimatedSprite2D
@onready var audioplayer = $AudioStreamPlayer2D

var hp = max_hp
var ground_count = 0
var is_touching_wall = false
var can_climb_wall = false
var is_dashing = false
var dashing_time = 0
var dash_cooldown = 0
var pressed_jump = false
var press_length = 0
var time_in_air = 0
var facing_right = true
var anim = ''
var disabled_movement = 0
var disabled_damage = 0
var is_dying = false
var death_time = 0
var money = 0
var golden_keys = 0
var silver_keys = 0

func flip():
	facing_right = !facing_right
	scale.x = -1

func play_sound(res, pos, pitch_scale=1):
	audioplayer.pitch_scale = pitch_scale
	audioplayer.stream = load("res://" + res)
	audioplayer.play(pos)

func get_input():
	if disabled_movement > 0:
		return
	if Input.is_action_pressed("left"):
		if facing_right:
			flip()
		if !is_touching_wall:
			velocity.x += -acc
			anim = 'run'
	elif Input.is_action_pressed("right"):
		if !facing_right:
			flip()
		if !is_touching_wall:
			velocity.x += acc
			anim = 'run'
	else:
		if anim == 'run':
			anim = 'idle'
	#if Input.is_action_pressed("up"):
	#	if is_touching_wall and can_climb_wall:
	#		velocity.y = -climbing_speed
	#		anim = 'climb'
	#elif Input.is_action_pressed("down"):
	#	if is_touching_wall:
	#		velocity.y = climbing_speed
	#		anim = 'climb'
	#elif is_touching_wall:
	#	anim = 'hanging'
	if Input.is_action_just_pressed("dash"):
		play_sound("whoosh.wav", 0.05)
		# Dash off the wall
		if is_touching_wall and dash_cooldown >= dash_cooldown_time:
			is_dashing = true
			velocity.x = -speed
			if sprite.flip_h:
				velocity.x *= -1
			dash_cooldown = 0
			flip()
		if dash_cooldown >= dash_cooldown_time:
			velocity.x = speed
			if !facing_right:
				velocity.x *= -1
			is_dashing = true
			dash_cooldown = 0
	if Input.is_action_just_pressed("jump"):
		pressed_jump = true
		press_length = 0
	if Input.is_action_just_released("jump") or press_length >= max_press_length:
		# Player released button after auto-release
		if not pressed_jump:
			return
		pressed_jump = false
		if (ground_count > 0) or is_touching_wall or time_in_air <= jump_forgiveness_time:
			play_sound('jump.wav', 0.3)
			if ground_count > 0:
				time_in_air = jump_forgiveness_time
			press_length = clamp(press_length, 0, max_press_length)
			var p_coeff = press_length/max_press_length
			velocity.y = -jump_speed*p_coeff
			if is_touching_wall:
				var facing = 1
				# Left
				if !facing_right:
					facing = -1
				velocity.x = -facing*speed
				flip()
	

func _ready():
	sprite.play('idle')
	anim = 'idle'

func apply_friction():
	var friction = -friction_coeff*velocity.x
	velocity.x += friction

func _process(delta):
	if is_dying:
		#death_time -= delta
		#if death_time <= 0:
		#	resurrect()
		if not sprite.is_playing():
			get_tree().change_scene_to_file("res://game_over.tscn")
		return
	if disabled_movement > 0:
		disabled_movement -= delta
	if disabled_damage > 0:
		disabled_damage -= delta
	if hp <= 0:
		die()
	if pressed_jump:
		press_length += delta
	if is_dashing:
		dashing_time += delta
		if dashing_time >= max_dashing_time:
			is_dashing = false
			dashing_time = 0
			#velocity.x = 0
	else:
		dash_cooldown += delta
	if is_dashing and anim != 'dashing':
		anim = 'dashing'
	elif !(ground_count > 0) and !is_touching_wall and !is_dashing:
		anim = 'jump'
	if anim == 'jump' and ground_count > 0:
		anim = 'idle'
	if anim == 'jump' and is_touching_wall:
		anim = 'hanging'
	if anim == 'dashing' and !is_dashing:
		anim = 'jump'
	if anim == 'climb' and !can_climb_wall:
		anim = 'hanging'
		#velocity.y += -jump_speed
		#is_touching_wall=false
	sprite.play(anim)

func ensure_dashing():
	if is_dashing:
		velocity.x *= dash_speed_coeff
		velocity.y = 0
	
func freefall(delta):
	velocity.y += G
	time_in_air += delta

func _physics_process(delta):
	if ground_count > 0:
		apply_friction()
		time_in_air = 0
	else:
		freefall(delta)
		
	get_input()
	velocity.x = clamp(velocity.x, -speed, speed)
	ensure_dashing()
	move_and_slide()

func die():
	velocity = Vector2.ZERO
	death_time = 2
	is_dying = true
	anim = 'death'
	sprite.play(anim)
	
func resurrect():
	position = safe_point
	#disabled_movement = 0.1
	is_dying = false
	anim = 'idle'
	sprite.play('idle')
	death_time = 0
	hp = max_hp

func check_data(tlmap, rid, data):
	var tile_coord = tlmap.get_coords_for_body_rid(rid)
	var val = null
	for lyr in tlmap.get_layers_count():
		var tile_data:TileData = tlmap.get_cell_tile_data(lyr, tile_coord)
		if not (tile_data is TileData):
			continue
		if tile_data.get_custom_data(data):
			val = tile_data.get_custom_data(data)
	return val
	
func delete_tile(tlmap : TileMap, rid):
	var tile_coord = tlmap.get_coords_for_body_rid(rid)
	tlmap.set_cell(0, tile_coord)

func check_water(tlmap : TileMap, rid):
	return check_data(tlmap, rid, "is_water")

func check_damaging(tlmap : TileMap, rid):
	return check_data(tlmap, rid, "damage")
	
func check_money(tlmap : TileMap, rid):
	return check_data(tlmap, rid, "money")

func water_death():
	disabled_movement = 2
	await get_tree().create_timer(1).timeout
	#get_tree().reload_current_scene()
	SceneChange.change_scene("res://game_over.tscn")
	
func get_damaged(dmg):
	if disabled_damage > 0:
		return
	if velocity.y == 0:
		velocity.y = -jump_speed
	var f = -1 if facing_right else 1
	velocity.x = speed*f
	disabled_movement = 0.3
	hp -= dmg
	disabled_damage = 0.5
	play_sound("hurt.wav", 0.2)

func _on_ground_area_body_shape_entered(body_rid, body, _body_shape_index, _local_shape_index):
	if body.is_in_group('ground'):
		ground_count += 1
		
	if body is TileMap:
		var c_dmg = check_damaging(body, body_rid)
		var c_mny = check_money(body, body_rid)
		if check_water(body, body_rid):
			water_death()
		elif c_dmg and c_dmg > 0:
			get_damaged(c_dmg)
		elif c_mny and c_mny > 0:
			print('here')
			money += c_mny
			delete_tile(body, body_rid)

func _on_ground_area_body_shape_exited(_body_rid, body, _body_shape_index, _local_shape_index):
	if body.is_in_group('ground'):
		ground_count -= 1

func get_coin(coin):
	play_sound("coin.wav", 0.1)
	money += coin.get_meta('value')
	coin.queue_free()
	
func get_heart(heart):
	play_sound("coin.wav", 0.1, 0.8)
	hp += heart.get_meta('hp')
	hp = min(hp, max_hp)
	heart.queue_free()

func open_golden_door(door):
	if !door.is_closed:
		return
	play_sound("door.wav", 0.4)
	door.open()
	golden_keys -= 1

func open_silver_door(door):
	if !door.is_closed:
		return
	play_sound("door.wav", 0.4)
	door.open()
	silver_keys -= 1
	
func finish():
	anim = 'idle'
	sprite.play(anim)
	disabled_movement = 2
	await get_tree().create_timer(0.8).timeout
	SceneChange.change_scene("res://won.tscn")

func _on_ground_area_area_entered(area):
	if area.is_in_group('coin'):
		get_coin(area)
	elif area.is_in_group('heart'):
		get_heart(area)
	elif area.is_in_group('golden_key'):
		golden_keys += 1
		play_sound("coin.wav", 0.1, 1.3)
		area.queue_free()
	elif area.is_in_group('silver_key'):
		silver_keys += 1
		play_sound("coin.wav", 0.1, 1.2)
		area.queue_free()
	elif area.is_in_group('golden_door'):
		if golden_keys > 0:
			open_golden_door(area)
	elif area.is_in_group('silver_door'):
		if silver_keys > 0:
			open_silver_door(area)
	elif area.is_in_group('spike'):
		get_damaged(max_hp/4)
	elif area.is_in_group('finish'):
		finish()
