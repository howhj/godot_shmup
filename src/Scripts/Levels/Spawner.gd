extends Node2D

var _wave_ptr = 0
var _enemy_ptr = 0
var _done_spawning = false
var dead = 0

onready var _timer = $Timer
onready var _charger = preload("res://src/Actors/Enemies/Charger.tscn")
onready var _pod_master = preload("res://src/Actors/Enemies/PodMaster.tscn")
onready var _enemy1 = preload("res://src/Actors/Enemies/Enemy1.tscn")
onready var _enemy2 = preload("res://src/Actors/Enemies/Enemy2.tscn")
onready var _enemy3 = preload("res://src/Actors/Enemies/Enemy3.tscn")

func _ready():
	_timer.start(1)

func _physics_process(_delta):
	## skip to next wave if all enemies are killed
	#if _done_spawning and dead == _pos_array[_wave_ptr-1].size():
	#	_done_spawning = false
	#	_timer.stop()
	#	_timer.start(0)
	pass

func _on_Timer_timeout():
	match _wave_ptr:
		0:
			if _enemy_ptr < 30:
				var pos = Vector2(0, -10)
				pos.x = Globals.rng.randf_range(-10, Globals.viewport.x + 10)
				Globals.instantiate(_charger, 2, pos)
				_enemy_ptr += 1
				_timer.start(0.1)
			else:
				_wave_ptr += 1
				_enemy_ptr = 0
				_timer.start(0.5)
		1:
			if _enemy_ptr < 8:
				match _enemy_ptr % 2:
					0:
						Globals.instantiate(_enemy1, 2, Vector2(350, -10))
					1:
						Globals.instantiate(_enemy2, 2, Vector2(350, -10))
				_enemy_ptr += 1
			else:
				Globals.instantiate(_enemy3, 2, Vector2(350, -10))
				_wave_ptr += 1
				_enemy_ptr = 0
		2:
			pass
	
	#if _wave_ptr == _pos_array.size():
	#	pass ## end the game
	#elif _enemy_ptr == _pos_array[_wave_ptr].size():
	#	_wave_ptr += 1
	#	_enemy_ptr = 0
	#	_done_spawning = true
	#	_timer.start(0.5) ## wait
	#else:
	#	Globals.instantiate(_enemy_array[_wave_ptr][_enemy_ptr], 2, _pos_array[_wave_ptr][_enemy_ptr])
	#	_enemy_ptr += 1
	#	_timer.start(0.2) ## to next spawn
