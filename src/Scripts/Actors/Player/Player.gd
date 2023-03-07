extends KinematicBody2D

var _cam_scale
export (float) var bullet_length = 3.0

export (int) var fire_rate = 30
var frames_per_shot
var _frame_count = 0

var _option_angle = 0
export (float) var option_offset = 15.0
export (float) var option_shot_angle = 25.0

export (float) var speed = 500.0
var focus = false
var _anim_state = 0

export var respawn_pos = Vector2(384, 950)
var _is_invul = true

var _hyper_meter = 0
export (int) var hyper_meter_cap = 100
var _hypers = 0
export (int) var hyper_cap = 5
export (float) var _hyper_duration = 10  ## doj is 20s static

var _bombs
export (int) var bomb_cap = 3
export (int) var bomb_damage = 50

onready var _bullet_spawner = $BulletSpawner
onready var _respawn_timer = $RespawnTimer
onready var _invul_timer = $InvulTimer
onready var _hyper_timer = $HyperTimer
onready var _sprite = $AnimatedSprite
onready var _optionL = $OptionL
onready var _optionR = $OptionR

const Bullet = preload("res://src/Actors/PlayerBullet.tscn")
const Explosion = preload("res://src/Effects/Explosion2.tscn")
const Bomb = preload("res://src/Effects/Explosion.tscn")  ## load bomb animation

func _ready():
	frames_per_shot = 60 / fire_rate
	option_shot_angle = deg2rad(option_shot_angle) - PI / 2
	_bombs = bomb_cap
	
	_cam_scale = Globals.cam_scale
	scale = _cam_scale
	bullet_length *= _cam_scale.y
	
	_invul(2)
	set_global_position(respawn_pos)
	Globals.player = self
	Globals.viewport = get_viewport_rect().size

func _physics_process(_delta):
	if is_visible():
		_get_input()
	
	if Globals.is_bombing: ## temporary
		var pos = Vector2()
		pos.x = Globals.rng.randf_range(50, Globals.viewport.x - 50)
		pos.y = Globals.rng.randf_range(50, Globals.viewport.y - 50)
		var size = Globals.rng.randf_range(1, 10)
		Globals.instantiate(Bomb, 1, pos, size)

func _get_input():
	var horizontal = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var vertical = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	if Input.get_action_strength("focus") > 0:
		focus = true
	else:
		focus = false
	_move(horizontal, vertical)
	_animate(horizontal)
	_move_options()
	
	if Input.get_action_strength("shoot") > 0:
		if _frame_count == 0:
			_shoot()
		_frame_count = (_frame_count + 1) % frames_per_shot
	
	if Input.get_action_strength("hyper") > 0 and _hypers > 0 and Globals.hyper_level == 0:
		_hyper()
	
	if Input.get_action_strength("bomb") > 0 and _bombs > 0 and not Globals.is_bombing:
		_bomb()

func _move(horizontal, vertical):
	var speed_mul = 1
	if focus:
		speed_mul = 0.66
	var velocity = Vector2(horizontal, vertical).normalized() * speed * speed_mul
	move_and_slide(velocity)
	
	var pos = get_global_position()
	var x_offset = 8 * _cam_scale.x
	var y_offset = 12 * _cam_scale.y
	pos.x = clamp(pos.x, x_offset, Globals.viewport.x - x_offset)
	pos.y = clamp(pos.y, y_offset, Globals.viewport.y - y_offset)
	set_global_position(pos)
	
func _animate(horizontal):
	if horizontal < 0:
		match _anim_state:
			-1:
				_sprite.play("left_hold")
			0:
				_sprite.play("left_bank")
				_anim_state = -2
			1:
				_sprite.play("right_return")
				_anim_state = 3
	elif horizontal == 0:
		match _anim_state:
			-1:
				_sprite.play("left_return")
				_anim_state = -3
			0:
				_sprite.play("default")
			1:
				_sprite.play("right_return")
				_anim_state = 3
	else:
		match _anim_state:
			-1:
				_sprite.play("left_return")
				_anim_state = -3
			0:
				_sprite.play("right_bank")
				_anim_state = 2
			1:
				_sprite.play("right_hold")

func _move_options():
	var target
	if focus:
		target = deg2rad(-70)
	else:
		target = 0
	
	var angle_offset = target - _option_angle
	if angle_offset < deg2rad(5) and angle_offset > deg2rad(-5):
		_option_angle = target
	elif _option_angle < target:
		_option_angle += deg2rad(14)
	else:
		_option_angle -= deg2rad(14)
	
	var target_pos_r = Vector2(cos(_option_angle), sin(_option_angle)) * option_offset
	var target_pos_l = target_pos_r * Vector2(-1, 1)
	
	_optionR.position = lerp(_optionR.position, target_pos_r, 0.5)
	_optionL.position = lerp(_optionL.position, target_pos_l, 0.5)

func _shoot():
	for i in 5:
		var offset = Vector2((i - 2) * 15, bullet_length * -2)
		var pos = _bullet_spawner.get_global_position() + offset
		var instance = Globals.instantiate(Bullet, 3, pos)
		instance.scale.y = bullet_length
		instance.direction = Vector2(0, -1)
	
	var option_dir
	if focus:
		option_dir = Vector2(0, -1)
	else:
		option_dir = Vector2(cos(option_shot_angle), sin(option_shot_angle))
	
	_optionR.shoot(option_dir)
	_optionL.shoot(option_dir * Vector2(-1, 1))

func gain_meter(value):
	if _hypers < hyper_cap:
		_hyper_meter += value
		if _hyper_meter > hyper_meter_cap:
			_hypers += 1
			if _hypers < hyper_cap:
				_hyper_meter -= hyper_meter_cap
			else:
				_hyper_meter = 0

func _hyper():
	Globals.hyper_level = _hypers
	Globals.rank_change(5 * _hypers)
	Globals.hit(0)
	
	_screen_clear()
	_invul(1)
	_hypers = 0
	_hyper_timer.start(_hyper_duration)

func _hyper_end():
	if Globals.hyper_level > 0:
		Globals.rank_change(-2 * Globals.hyper_level)
		Globals.hyper_level = 0

func _bomb():
	Globals.is_bombing = true
	Globals.chain_break()
	_hyper_end()
	_hyper_timer.stop()
	
	_screen_clear()
	_invul(2)
	_bombs -= 1

func _die():
	_hyper_end()
	_hyper_timer.stop()
	
	Globals.instantiate(Explosion, 5, get_global_position(), 1)
	hide()
	_invul(4)
	_respawn_timer.start()

func _screen_clear():
	for bullet in get_node("../../EnemyBullets").get_children():
		bullet.queue_free()

func _invul(time):
	_is_invul = true
	_invul_timer.start(time)

func _on_Hitbox_body_entered(_body):
	if not _is_invul:
		_die()

func _on_ItemHitbox_body_entered(body):
	if is_visible():
		Globals.score += body.value * Globals.chain_multiplier
		Globals.medal_chain = body.tier
		
		if body.tier < 5:
			gain_meter(2)
		elif body.tier < 10:
			gain_meter(5)
		else:
			gain_meter(10)
		
		body.queue_free()

func _on_RespawnTimer_timeout():
	if not is_visible():
		Globals.rank_change(-20)
		Globals.is_dead = true
		
		set_global_position(respawn_pos)
		show()
		gain_meter(50)
		_bombs = bomb_cap
		_respawn_timer.start()
	else:
		Globals.is_dead = false

func _on_InvulTimer_timeout():
	_is_invul = false
	Globals.is_bombing = false

func _on_HyperTimer_timeout():
	_hyper_end()
	_screen_clear()
	_invul(1)

func _on_AnimatedSprite_animation_finished():
	if _anim_state == 2:
		_anim_state = 1
	elif _anim_state == -2:
		_anim_state = -1
	elif _anim_state == 3 or _anim_state == -3:
		_anim_state = 0
