extends KinematicBody2D

export (float) var max_speed = 350.0
export (float) var acceleration = 1000.0

var hori_speed = 0
var fall_speed = -500.0
var velocity = Vector2()
var value
var tier
var auto_collect = false
var go_to_player = false

onready var _sprite = $Sprite

func _ready():
	tier = Globals.medal_chain
	if tier < 10:
		tier += 1
	
	if tier < 5:
		value = tier * 200
	elif tier < 10:
		value = (tier - 4) * 1000
	else:
		value = 10000
	
	match tier:
		1:
			_sprite.texture = load("res://assets/medals/200_medal.png")
		2:
			_sprite.texture = load("res://assets/medals/400_medal.png")
		3:
			_sprite.texture = load("res://assets/medals/600_medal.png")
		4:
			_sprite.texture = load("res://assets/medals/800_medal.png")
		5:
			_sprite.texture = load("res://assets/medals/1k_medal.png")
		6:
			_sprite.texture = load("res://assets/medals/2k_medal.png")
		7:
			_sprite.texture = load("res://assets/medals/3k_medal.png")
		8:
			_sprite.texture = load("res://assets/medals/4k_medal.png")
		9:
			_sprite.texture = load("res://assets/medals/5k_medal.png")
		10:
			_sprite.texture = load("res://assets/medals/10k_medal.png")
	
	if tier == 5:
		scale *= 2
	elif tier > 5:
		scale *= 1.5

func _physics_process(delta):
	if fall_speed < max_speed:
		fall_speed += acceleration * delta
		if fall_speed > max_speed:
			fall_speed = max_speed
		elif auto_collect and fall_speed > -150:
			go_to_player = true
	
	var pos = get_global_position()
	## set offset depending on sprite size
	if (pos.x + 10 >= Globals.viewport.x and hori_speed > 0) or (pos.x - 10 <= 0 and hori_speed < 0):
		hori_speed *= -1
	
	if hori_speed < 10 and hori_speed > -10:
		hori_speed = 0
	else:
		hori_speed = lerp(hori_speed, 0, 0.05)
	
	if go_to_player:
		var direction = Globals.player.get_global_position() - get_global_position()
		move_and_slide(direction.normalized() * 1000)
	else:
		move_and_slide(Vector2(hori_speed, fall_speed))
	
	## set offset depending on sprite size
	if pos.y >= Globals.viewport.y + 8:
		Globals.medal_chain = 0

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
