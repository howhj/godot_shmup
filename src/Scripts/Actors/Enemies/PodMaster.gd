extends "res://src/Scripts/Actors/Enemy.gd"

export (float) var speed = 300
var slave_pos = []

onready var _pod_slave = preload("res://src/Actors/Enemies/PodSlave.tscn")

func _ready():
	for pos in slave_pos:
		var instance = Globals.instantiate(_pod_slave, -1, pos)
		instance.parent = self

func _physics_process(_delta):
	move_and_slide(Vector2(0, speed))

func take_damage(damage):
	for child in get_children():
		child.take_damage(damage)

func _on_PodMaster_died():
	if not Globals.is_bombing:
		var remaining = get_child_count()
		for child in get_children():
			child.point_value *= remaining
			child.spawn_medals(1)
			child.take_damage(child.max_hp)
