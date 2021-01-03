extends TextureButton

onready var time_label = $Counter/Value

export var cooldown = .4

func _ready():
	$Timer.wait_time = cooldown
	time_label.hide()
	$Sweep.texture_progress = texture_normal
	$Sweep.value = 0
	set_process(false)

func _process(delta):
	time_label.text = "%3.1f" % $Timer.time_left
	$Sweep.value = int(($Timer.time_left / cooldown) * 100)

func _on_AbilityButton_pressed():
	disabled = true
	set_process(true)
	$Timer.start()
	time_label.show()

func _on_Timer_timeout():
	print("ability ready")
	$Sweep.value = 0
	disabled = false
	time_label.hide()
	set_process(false)
