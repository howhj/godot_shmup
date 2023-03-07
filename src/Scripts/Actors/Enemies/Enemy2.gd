extends "res://src/Scripts/Actors/Enemy.gd"

var _choice = 0
var _count = 0

onready var _bullet_spawner_m = $BulletSpawnerM
onready var _bullet_spawner_l = $BulletSpawnerL
onready var _bullet_spawner_r = $BulletSpawnerR
onready var _shoot_timer = $ShootTimer

const Bullet = preload("res://src/Actors/EnemyBullet.tscn")

func _ready():
	max_hp = 50
	is_invul = false

func _physics_process(_delta):
	move_and_slide(Vector2(0, 100))

func _shootM():
	var pos = _bullet_spawner_m.get_global_position()
	for i in 5:
		var instance = Globals.instantiate(Bullet, 6, pos)
		var angle = deg2rad(50 + i * 20)
		instance.direction = Vector2(cos(angle), sin(angle))

func _shootLR():
	var player_pos = Globals.player.get_node("Hitbox").get_global_position()
	
	var pos_l = _bullet_spawner_l.get_global_position()
	var instance_l = Globals.instantiate(Bullet, 6, pos_l)
	instance_l.direction = (player_pos - pos_l).normalized()
	
	var pos_r = _bullet_spawner_r.get_global_position()
	var instance_r = Globals.instantiate(Bullet, 6, pos_r)
	instance_r.direction = (player_pos - pos_r).normalized()

func _on_ShootTimer_timeout():
	if _choice == 0:
		if not Globals.is_dead:
			_shootM()
		_choice = 1
		_shoot_timer.start(1)
	else:
		if not Globals.is_dead:
			_shootLR()
		_count += 1
		if _count < 3:
			_shoot_timer.start(0.2)
		else:
			_choice = 0
			_count = 0
			_shoot_timer.start(1)
