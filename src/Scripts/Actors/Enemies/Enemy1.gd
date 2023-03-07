extends "res://src/Scripts/Actors/Enemy.gd"

export (int) var speed = 300
export (int) var dest_y = 300

var _state = 0
var _dest
var _retreat_angle

var _max_shots = 1
var _shot_ctr = 0
var _wait_time = 0.5
var is_shooting = false
var shot_speed = 0
var _player_pos

const Bullet = preload("res://src/Actors/EnemyBullet.tscn")

onready var _wait_timer = $WaitTimer
onready var _timer = $ShootTimer
onready var _bullet_spawner = $BulletSpawner

func _ready():
	dest_y = dest_y + Globals.rng.randf_range(-20, 20)
	#_dest = Vector2(get_global_position().x, dest_y) ## not working for some reason
	
	if Globals.rank > 50:
		_max_shots = 10
		_wait_time = 0.1
		shot_speed = 300

func _physics_process(_delta):
	if _dest == null:
		_dest = Vector2(get_global_position().x, dest_y)
	
	if not is_dead:
		var pos = get_global_position()
		match _state:
			0:
				set_global_position(lerp(pos, _dest, 0.03))
				var offset = pos.y - dest_y
				if offset < 100 and offset > -100:
					can_shoot = true
					is_invul = false
				if offset < 10 and offset > -10:
					_state = 1
					_wait_timer.start()
			2:
				if not is_shooting:
					can_shoot = false
					_state = 3
					if get_global_position().x < Globals.viewport.x / 2:
						_retreat_angle = deg2rad(250)
					else:
						_retreat_angle = deg2rad(290)
			3:
				rotation = lerp_angle(rotation, _retreat_angle - PI / 2, 0.1)
				var offset = rad2deg(rotation - _retreat_angle - PI / 2)
				if offset < 10 and offset > -10:
					_state = 4
		
		if _state < 3:
			move_and_slide(Globals.cam_velocity)
		else:
			var direction = Vector2(cos(_retreat_angle), sin(_retreat_angle))
			move_and_slide(direction * speed)
	else:
		move_and_slide(Globals.cam_velocity)

func shoot(target):
	var pos = _bullet_spawner.get_global_position()
	var vector = target - pos
	if vector.length() > 200:
		var instance = Globals.instantiate(Bullet, 6, pos)
		instance.direction = vector.normalized()
		instance.speed += Globals.rank + shot_speed

func _on_WaitTimer_timeout():
	_state = 2

func _on_ShootTimer_timeout():
	if can_shoot and not is_shooting:
		is_shooting = true
		if not Globals.is_dead:
			_player_pos = Globals.player.get_node("Hitbox").get_global_position()
		else:
			_player_pos = null
			
	if is_shooting:
		if _player_pos != null:
			shoot(_player_pos)
			
		_shot_ctr += 1
		if _shot_ctr < _max_shots:
			_timer.start(0.05)
		else:
			_timer.start(_wait_time)
			_shot_ctr = 0
			is_shooting = false
