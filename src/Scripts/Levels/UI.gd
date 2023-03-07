extends Node2D

onready var _score = $Score
onready var _chain = $Chain
onready var _multiplier = $Multiplier
onready var _chain_timer_debug = $Chain_timer_debug
onready var _hyper_gauge_debug = $Hyper_gauge_debug
onready var _hyper_level_debug = $Hyper_level_debug
onready var _hyper_timer_debug = $Hyper_timer_debug

func _ready():
	_chain.hide()
	_multiplier.hide()

func _physics_process(_delta):
	_score.text = str(Globals.score)
	
	if Globals.hit_chain < 10:
		_chain.hide()
		_multiplier.hide()
	else:
		_chain.show()
		_chain.text = str(Globals.hit_chain) + " HITS!"
	
	if Globals.chain_multiplier > 1:
		_multiplier.show()
		_multiplier.text = "x" + str(Globals.chain_multiplier)
	
	_chain_timer_debug.text = "Chain: " + str(Globals._hit_timer)
	_hyper_gauge_debug.text = "Gauge: " + str(Globals.player._hyper_meter)
	_hyper_level_debug.text = "Level: " + str(Globals.player._hypers)
	_hyper_timer_debug.text = "Timer: " + str(Globals.player._hyper_timer.time_left)
