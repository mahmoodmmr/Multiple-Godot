extends Window

@onready var _Camera: Camera2D = $ViewCamera

var world_offset: = Vector2i.ZERO
var last_position: = Vector2i.ZERO
var velocity: = Vector2i.ZERO
var focused: = false

var enable_border = true
var enable_unresizable = true
var enable_always_on_top = true
var enable_gui_embed_subwindows = false
var enable_transparent = true
var enable_transparent_bg = true

func _ready() -> void:
	#borderless = enable_border
	unresizable = enable_unresizable
	always_on_top = enable_always_on_top	# Force the window always be on top of the screen
	gui_embed_subwindows = enable_gui_embed_subwindows # Make subwindows actual system windows <- VERY IMPORTANT
	#transparent = enable_transparent		# Allow the window to be transparent
	#transparent_bg = enable_transparent_bg	# Make the window's background transparent
	
	_Camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	
	transient = true # Make the window considered as a child of the main window
	close_requested.connect(queue_free) # Actually close the window when clicking the close button

func _process(delta: float) -> void:
	velocity = position - last_position
	last_position = position
	_Camera.position = get_camera_pos_from_window()

func get_camera_pos_from_window()->Vector2i:
	return (position + velocity - world_offset) / Vector2i(_Camera.zoom)
