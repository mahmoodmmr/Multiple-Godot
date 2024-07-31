extends MovementProvider

@export_placeholder("ui_left") var action_left: String
@export_placeholder("ui_right") var action_right: String
@export_placeholder("ui_up") var action_up: String
@export_placeholder("ui_down") var action_down: String
@export_placeholder("ui_select") var action_jump: String
@export var allow_bunnyhop: bool = false # not implemented yet

func _process(delta):
	super._process(delta)
	provider_dir = Input.get_axis(action_left, action_right)
	provider_dir_ver = Input.get_axis(action_up, action_down)
	provider_jump = Input.is_action_pressed(action_jump)
