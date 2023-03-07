extends Node

var rank = 0
const _rank_cap = 100
var rng
var player
var viewport
var bomb_damage = 5
var is_bombing = false
var is_dead = false

var score = 0
var medal_chain = 0
var hit_chain = 0
var _hit_timer = 0
const _hit_timer_cap = 60
var chain_multiplier = 1
var hyper_level = 0
var no_miss = true

const cam_scale = Vector2(3, 3)
const cam_velocity = Vector2(0, 50)

func _ready():
	reset()

func _physics_process(_delta):
	if _hit_timer > 0:
		_hit_timer -= 1
		if _hit_timer == 0:
			chain_break()
	
	if hit_chain < 100:
		chain_multiplier = hit_chain / 20 * 0.2 + 1
	elif hit_chain < 500:
		chain_multiplier = hit_chain / 50
	else:
		chain_multiplier = 10

func reset():
	rank = 0
	rng = RandomNumberGenerator.new()
	rng.randomize()
	is_bombing = false
	is_dead = false
	
	score = 0
	medal_chain = 0
	hit_chain = 0
	_hit_timer = 0
	chain_multiplier = 1
	hyper_level = 0
	no_miss = true

func instantiate(prefab, parent, pos, scale_mul=1):
	var instance = prefab.instance()
	var parent_node
	match parent:
		0:
			parent_node = get_node("/root/Level/GroundEnemies")
		1:
			parent_node = get_node("/root/Level/GroundItems")
		2:
			parent_node = get_node("/root/Level/AirEnemies")
		3:
			parent_node = get_node("/root/Level/PlayerBullets")
		4:
			parent_node = get_node("/root/Level/AirItems")
		5:
			parent_node = get_node("/root/Level/PlayerLayer")
		6:
			parent_node = get_node("/root/Level/EnemyBullets")
	
	if not parent == -1:
		parent_node.call_deferred("add_child", instance)
	instance.set_deferred("global_position", pos)
	instance.scale *= cam_scale * scale_mul
	return instance

func hit(value):
	_hit_timer = _hit_timer_cap
	hit_chain += value

func chain_break():
	_hit_timer = 0
	hit_chain = 0

func rank_change(delta):
	rank += delta
	if rank > _rank_cap:
		rank = _rank_cap
	elif rank < 0:
		rank = 0

## high scores
