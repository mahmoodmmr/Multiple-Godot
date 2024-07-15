extends CharacterBody2D

# From A Key(s) Path
# Movement exports
@export_group("Movement")
@export var max_speed: float = 120.0 # Player max speed in px/s
@export var jump_height: float = 40.0 # px
#@export var gravity: float = 310.0 # px/s/s
#@export var gravity_strong: float = 650.0 # px/s/s
@export var gravity: float = 0.0 # px/s/s
@export var gravity_strong: float = 0.0 # px/s/s
@export var acceleration: float = 512.0 # px/s/s
@export var deceleration: float = 1024.0 # px/s/s
# Buffers
@export_group("Buffers")
@export var air_buffer = 0.1
@export var jump_buffer = 0.07

@onready var _Sprite = $Sprite
@onready var _Collision = $Collider
@onready var _AnimationTree: AnimationTree = $AnimationTree
@onready var _StateMachine: AnimationNodeStateMachinePlayback = _AnimationTree["parameters/playback"]

# Provided values
var dir: float = 0.0
var jump: bool = false

var target_speed: float = 0.0
var target_accel: float = 0.0
var target_gravity: float = gravity_strong
var air_time = air_buffer
var jump_time = jump_buffer
var on_ground: bool = false

# New variable to control manual movement
var manual_control: bool = true

func _process(_delta):
	#var mouse_position = get_global_mouse_position()
	#var pointerKazem = (mouse_position - position).normalized()
	#
	#position += pointerKazem * 200 * _delta
	#if pointerKazem.x > 0:
		#target_speed = 1.0
	#elif pointerKazem.x  < 0:
		#target_speed = -1.0 
	#elif pointerKazem.x  == 0:
		#target_speed = 0
	if manual_control:
		handle_manual_control(_delta)
	else:
		# Only update the animation if manual control is off
		if target_speed < 0.0:
			_Sprite.flip_h = true
		elif target_speed > 0.0:
			_Sprite.flip_h = false

		# Animation states
		if on_ground:
			if target_speed != 0.0:
				_StateMachine.travel("run")
			else:
				_StateMachine.travel("idle")
		else:
			if velocity.y >= 0.0:
				_StateMachine.travel("fall")

func _physics_process(delta):
	if manual_control:
		handle_manual_physics(delta)
		return # Skip the default behavior if manual control is enabled

	# Get horizontal movement direction
	# Direction is provided by a Movement Provider -> either a Player or IA

	# Vertical movement
	if velocity.y > 0 or (not jump and jump_time < jump_buffer):
		target_gravity = gravity_strong
	velocity.y += target_gravity * delta

	# Horizontal movement
	target_speed = dir * max_speed
	target_accel = acceleration if dir and sign(dir) == sign(velocity.x) else deceleration
	velocity.x = move_toward(velocity.x, target_speed, target_accel * delta)

	# Apply velocity
	var collision = move_and_slide()
	var landed = is_on_floor() and not on_ground

	# Update buffers
	if jump:
		jump_time = 0.0 # Reset jump time
	on_ground = is_on_floor()
	if on_ground:
		air_time = 0.0 # Reset air time
	else:
		air_time = min(air_time + delta, air_buffer)
		jump_time = min(jump_time + delta, jump_buffer)

	# Apply jump / landing
	if jump_time < jump_buffer and air_time < air_buffer:
		do_jump()
	elif landed:
		do_land()

func handle_manual_control(_delta):
	var input_dir = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		input_dir.x += 1
	if Input.is_action_pressed("ui_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_dir.y += 1
	if Input.is_action_pressed("ui_up"):
		input_dir.y -= 1

	position += input_dir.normalized() * max_speed * _delta

func handle_manual_physics(delta):
	# Handle gravity for manual control
	if Input.is_action_just_pressed("ui_up") and on_ground:
		velocity.y = -sqrt(jump_height * 2.0 * gravity)
		on_ground = false

	if not on_ground:
		velocity.y += gravity * delta

	position.y += velocity.y * delta

	# Reset on_ground if landed
	if is_on_floor():
		on_ground = true
		velocity.y = 0

func do_jump() -> void:
	# Movement variables
	velocity.y = -sqrt(jump_height * 2.0 * gravity)
	target_gravity = gravity

	# Status variables
	jump_time = jump_buffer
	air_time = air_buffer
	on_ground = false

	# Animation and effects
	_StateMachine.travel("jump")

func do_land() -> void:
	pass
