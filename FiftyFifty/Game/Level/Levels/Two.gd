extends Node2D

var thruster_tips_shown = false
var weapons_tips_shown = false

func _ready():
	$CanvasLayer/ThrusterTips.show()
	set_process_input(true)
	set_process(true)

func _input(event):
	if not thruster_tips_shown and event.is_action_pressed("jump_dash"):
		$CanvasLayer/ThrusterTips.hide()
		$CanvasLayer/WeaponTips.show()
		thruster_tips_shown = true
	if not weapons_tips_shown and event.is_action_pressed("lazer_teleport"):
		$CanvasLayer/WeaponTips.hide()
		weapons_tips_shown = true
