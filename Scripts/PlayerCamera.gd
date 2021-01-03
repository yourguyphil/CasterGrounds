extends Camera2D

var facing = 0

#Smooth out the camera shifts
const SHIFT_TRANSITION = Tween.TRANS_SINE
const SHIFT_EASE = Tween.EASE_OUT
const SHIFT_DURATION = 1.0
const LOOK_AHEAD_FACTOR = 0.1

onready var prev_camera_pos = get_camera_position()
onready var tween = $ShiftTween

func _ready():
	#_auto_set_limits()
	pass

func _process(delta):
	_check_facing()
	prev_camera_pos = get_camera_position()

func _check_facing():
	var new_facing = sign(get_camera_position().x  - prev_camera_pos.x)
	if new_facing != 0 and facing != new_facing:
		facing = new_facing
		var target_offset = get_viewport_rect().size.x * facing * LOOK_AHEAD_FACTOR
		#tween.interpolate_property(self, "position:x", position.x, target_offset, SHIFT_DURATION, SHIFT_TRANSITION, SHIFT_EASE)
		#tween.start()

func _on_Player_grounded_updated(is_grounded):
	#Make sure camera doesn't move while off the ground
	#drag_margin_v_enabled = !is_grounded
	pass
