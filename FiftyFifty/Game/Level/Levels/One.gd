extends Node2D

var movement_tips_completed_time = 0
var movement_tips_visible = false
var movement_tips_shown = false

func _ready():
	$CanvasLayer/MovementTips.show()
	$CanvasLayer/PortalTips.hide()
	set_process_input(true)
	set_process(true)

func _input(event):
	if event.is_action_pressed("move_left") or event.is_action_pressed("move_right"):
		$CanvasLayer/MovementTips.hide()
		movement_tips_completed_time = OS.get_ticks_msec()
	if movement_tips_visible and event.is_action_pressed("enter"):
		$CanvasLayer/PortalTips.hide()

func _process(_delta):
	if not movement_tips_shown and movement_tips_completed_time > 0 and OS.get_ticks_msec() - movement_tips_completed_time > 500:
		$CanvasLayer/PortalTips.show()
		movement_tips_visible = true
		movement_tips_shown = true
