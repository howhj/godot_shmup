extends Sprite

var _level
var _screen_height
var _offset

export (bool) var first = true

func _ready():
	_level = get_node("../..")
	_screen_height = get_viewport_rect().size.y
	scale = Globals.cam_scale
	_offset = texture.get_height() * scale.y
	
	if first:
		set_global_position(Vector2.ZERO)
	else:
		set_global_position(Vector2(0, -_offset))

func _physics_process(delta):
	translate(Globals.cam_velocity * delta)
	
	var pos = get_global_position()
	if pos.y >= _screen_height:
		set_global_position(Vector2(pos.x, pos.y - _offset * 2))
