extends KinematicBody2D

export (int) var speed = 200

var direction = Vector2()

func _ready():
	if Globals.is_bombing:
		queue_free()
	
func _physics_process(delta):
	move_and_collide(direction * speed * delta)
		
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
