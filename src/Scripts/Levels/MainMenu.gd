extends Node2D

var _state = 0
var _left_pos = Vector2(288, 513)
var _mid_pos = Vector2(336, 513)
var _right_pos = Vector2(408, 513)
var _input_lock = false

onready var _cursor = $Cursor
onready var _start_game = $StartGame
onready var _difficulty_modes = $DifficultyModes
onready var _quit = $Quit

func _ready():
	_main_menu()

func _physics_process(_delta):
	var pos = _cursor.get_global_position()
	
	## leaderboard screen
	if Input.get_action_strength("shoot") > 0:
		if not _input_lock:
			_input_lock = true
			match _state:
				0:
					Globals.reset()
					get_tree().change_scene("res://src/Levels/Level.tscn")
				1:
					match pos.x:
						_left_pos.x:
							get_tree().quit()
						_right_pos.x:
							_main_menu()
	
	elif Input.get_action_strength("focus") > 0:
		if not _input_lock:
			_input_lock = true
			_quit_prompt()
	
	else:
		_input_lock = false
	
	if Input.get_action_strength("move_left") > 0:
		if _state > 0 and pos.x > _left_pos.x:
			_cursor.set_global_position(_left_pos)
	
	elif Input.get_action_strength("move_right") > 0:
		if _state > 0 and pos.x < _right_pos.x:
			_cursor.set_global_position(_right_pos)

func _main_menu():
	_start_game.show()
	_quit.hide()
	_cursor.set_global_position(_mid_pos)
	_state = 0

func _quit_prompt():
	_start_game.hide()
	_quit.show()
	_cursor.set_global_position(_right_pos)
	_state = 1
