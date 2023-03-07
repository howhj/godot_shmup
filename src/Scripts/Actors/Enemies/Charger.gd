extends "res://src/Scripts/Actors/Enemy.gd"

export (float) var speed = 500
var direction = Vector2(0, 1)
var player_pos

func _ready():
	is_invul = false

func _physics_process(_delta):
	if not Globals.is_dead:
		player_pos = Globals.player.get_global_position()
		direction = (player_pos - get_global_position()).normalized()
	
	move_and_slide(direction * speed)
	rotation = direction.angle() - PI / 2
