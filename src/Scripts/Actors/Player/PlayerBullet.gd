extends KinematicBody2D

export (int) var speed = 1000

var damage
var direction = Vector2()

func _ready():
	## set hyper sprite if in hyper
	match Globals.hyper_level:
		0:
			damage = 1
		1:
			damage = 1.2
		2:
			damage = 1.4
		3:
			damage = 1.7
		4:
			damage = 2
		5:
			damage = 2.5

func _physics_process(delta):
	move_and_collide(direction * speed * delta)
		
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
