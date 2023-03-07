extends AnimatedSprite

export (float) var bullet_length = 3.0

onready var _bullet_spawner = $BulletSpawner

const Bullet = preload("res://src/Actors/PlayerBullet.tscn")

func _ready():
	bullet_length *= Globals.cam_scale.y

func shoot(direction):
	var ref = bullet_length * 3 * direction
	for i in 3:
		var perpendicular = ref.angle() + PI / 2 * (i - 1)
		var offset = ref + Vector2(cos(perpendicular), sin(perpendicular)) * 15
		var pos = _bullet_spawner.get_global_position() + offset
		var instance = Globals.instantiate(Bullet, 3, pos)
		instance.scale.y = bullet_length
		instance.direction = direction
		instance.rotation = direction.angle() + PI / 2
