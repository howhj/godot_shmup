extends "res://src/Scripts/Actors/Enemy.gd"

export (int) var speed = 300
export (int) var dest_y = 512
export (int) var spin_speed = 2

var _hover_dest = [Vector2(384, 512), Vector2(334, 462), Vector2(334, 562), Vector2(434, 462), Vector2(434, 562)]
var _next_dest
var _state = 0

var _offset = 0
var _wait_time = 1
var shot_speed = 0

var petals = 5
var density = 2
var _interval
var _sub_interval

onready var _wait_timer = $WaitTimer
onready var _bullet_spawner = $BulletSpawner
onready var _flower_timer = $FlowerTimer

const Bullet = preload("res://src/Actors/EnemyBullet.tscn")

func _ready():
	if Globals.rank > 50:
		_wait_time = 0.5
		_flower_timer.start(_wait_time)
		shot_speed = 50
	
	max_hp = 300
	explosion_count = 10
	custom_scale = 2 ## not working
	scale *= custom_scale
	_interval = 360 / petals
	_sub_interval = _interval / density / 2

func _physics_process(_delta):
	if not is_dead:
		var pos = get_global_position()
		match _state:
			0:
				var dest = Vector2(pos.x, dest_y)
				set_global_position(lerp(pos, dest, 0.05))
				var offset = pos.y - dest_y
				if offset < 100 and offset > -100:
					can_shoot = true
					is_invul = false
				if offset < 10 and offset > -10:
					_state = 1
					_wait_timer.start()
			1:
				_next_dest = _hover_dest[Globals.rng.randf_range(0, _hover_dest.size())]
				_state = 2
			2:
				set_global_position(lerp(pos, _next_dest, 0.01))
				if (_next_dest - pos).length() < 5:
					_state = 1
			3:
				move_and_slide(Vector2(0, -speed))
	else:
		move_and_slide(Globals.cam_velocity)

func _create_bullet(angle, speed=200, scale_mul=1):
	var pos = _bullet_spawner.get_global_position()
	var bullet_instance = Globals.instantiate(Bullet, 6, pos, scale_mul)
	bullet_instance.direction = Vector2(cos(angle), sin(angle))
	bullet_instance.speed = speed + Globals.rank + shot_speed

func shoot_flower():
	for i in petals:
		var player_pos = Globals.player.get_node("Hitbox").get_global_position()
		var direction = player_pos - _bullet_spawner.get_global_position()
		var base_angle = rad2deg(direction.angle()) + _interval * (i + 0.5)
		
		for j in density * 2:
			base_angle += _sub_interval
			var speed = 200
			if j < density:
				speed += 100 / density * (density - j)
			else:
				speed += 100 / density * (j - density)
			_create_bullet(deg2rad(base_angle), speed, custom_scale)

func shoot_lines(offset):
	for i in 5:
		var angle = deg2rad(270 + 72 * i + offset)
		_create_bullet(angle)

func _on_WaitTimer_timeout():
	_state = 3
	can_shoot = false
	is_invul = true
	
func _on_FlowerTimer_timeout():
	if can_shoot and not Globals.is_dead:
		shoot_flower()

func _on_LineTimer_timeout():
	if can_shoot and not Globals.is_dead:
		shoot_lines(_offset)
	_offset += spin_speed
