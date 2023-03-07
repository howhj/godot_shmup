extends KinematicBody2D

export (int) var max_hp = 1
export (float) var custom_scale = 1.0
export (int) var explosion_count = 1
export (bool) var drop_medal = false
export (int) var point_value = 1000

var pre_spawn = true
var is_invul = true
var can_shoot = false

var current_hp
var is_dead = false
var _explode_timer

onready var _hitbox = $Hitbox

const Explosion = preload("res://src/Effects/Explosion.tscn")
const Medal = preload("res://src/Actors/Medal.tscn")

signal exited
signal died

func _ready():
	current_hp = max_hp
	scale *= custom_scale
	
func _physics_process(_delta):
	if Globals.is_bombing:
		take_damage(Globals.bomb_damage)
#	if pre_spawn:
#		_body.move_and_slide(Globals.cam_velocity) ## probably need to change

func take_damage(damage):
	if not is_invul and not is_dead:
		current_hp -= damage
		if current_hp <= 0:
			if not Globals.is_bombing:
				Globals.hit(1 + Globals.hyper_level)
			Globals.score += point_value * Globals.chain_multiplier
			
			var collider = get_node_or_null("CollisionShape2D")
			if not collider == null:
				collider.scale = Vector2.ZERO
			can_shoot = false
			is_dead = true
			
			_explode_timer = get_node_or_null("ExplodeTimer")
			if (not _explode_timer == null) and explosion_count > 1:
				_explode_timer.start()
			else:
				_die()
	
func _explode(scale_mul=2, offset=Vector2.ZERO):
	var pos = get_global_position() + offset
	Globals.instantiate(Explosion, 2, pos, custom_scale * scale_mul)
	
func _die():
	_explode()
	if drop_medal:
		spawn_medals()
	emit_signal("died")
	queue_free()

func spawn_medals(medals = -1):
	var auto_collect = false
	if medals == -1:
		medals = 1
		var distance = get_global_position().distance_to(Globals.player.get_global_position())
		if distance < 200:
			medals = 3
			auto_collect = true
		elif distance < 400:
			medals = 2
		
		if Globals.hyper_level == 5:
			medals += 3
		elif Globals.hyper_level > 2:
			medals += 2
		elif Globals.hyper_level > 0:
			medals += 1
	
	for i in medals:
		var instance = Globals.instantiate(Medal, 4, get_global_position())
		instance.hori_speed = Globals.rng.randf_range(-500, 500)
		instance.fall_speed -= Globals.rng.randf_range(0, 100)
		if auto_collect:
			instance.auto_collect = true

func _on_VisibilityEnabler2D_screen_entered():
	pre_spawn = false

func _on_VisibilityNotifier2D_screen_exited():
	emit_signal("exited")
	queue_free()

func _on_Hitbox_body_entered(body):
	if not is_invul and not is_dead:
		Globals.score += 100
		take_damage(body.damage)
		body.queue_free()

func _on_ExplodeTimer_timeout():
	var x = Globals.rng.randf_range(-50, 50)
	var y = Globals.rng.randf_range(-50, 50)
	var offset = Vector2(x, y)
	_explode(1.25, offset)
	
	explosion_count -= 1
	if explosion_count > 1:
		_explode_timer.start()
	else:
		_die()
