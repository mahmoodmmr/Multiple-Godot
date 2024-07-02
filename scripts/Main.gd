extends Node

@export var player_size: Vector2i = Vector2i(32, 32) # Should be the size of your character sprite, or slightly bigger
@export var home_size: Vector2i = Vector2i(32, 32) # Should be the size of your character sprite, or slightly bigger
@export_range(0, 19) var player_visibility_layer: int = 1
@export_range(0, 19) var home_visibility_layer: int = 1
@export_range(0, 19) var world_visibility_layer: int = 0
@export_node_path("Camera2D") var main_camera: NodePath
@export_node_path("Camera2D") var home_camera: NodePath
@export var view_window: PackedScene
@export var creating_window: PackedScene
@export var sprite_array :Array[Sprite2D] = []

var world_offset: = Vector2i.ZERO

@onready var _MainCamera: Camera2D = get_node(main_camera)
@onready var _HomeCamera: Camera2D = get_node(home_camera)
@onready var _MainWindow: Window = get_window()
@onready var _HomeWindow: Window
@onready var _MainScreen: int = _MainWindow.current_screen
@onready var _MainScreenRect: Rect2i = DisplayServer.screen_get_usable_rect(_MainScreen)

func _ready():
	# ------------ MAIN WINDOW SETUP ------------
	# Enable per-pixel transparency, required for transparent windows but has a performance cost
	# Can also break on some systems
	ProjectSettings.set_setting("display/window/per_pixel_transparency/allowed", true)
	# Set the window settings - most of them can be set in the project settings
	_MainWindow.borderless = true		# Hide the edges of the window
	_MainWindow.unresizable = true		# Prevent resizing the window
	_MainWindow.always_on_top = true	# Force the window always be on top of the screen
	_MainWindow.gui_embed_subwindows = false # Make subwindows actual system windows <- VERY IMPORTANT
	_MainWindow.transparent = true		# Allow the window to be transparent
	# Settings that cannot be set in project settings
	_MainWindow.transparent_bg = true	# Make the window's background transparent
	
	# The window's size may need to be smaller than the default minimum size
	# so we have to change the minimum size BEFORE setting the window's size
	_MainWindow.min_size = player_size * Vector2i(_MainCamera.zoom)
	_MainWindow.size = _MainWindow.min_size
	# To only see the character in the main window, we need to 
	# move its sprite on a separate visibility layer from the world
	# and set the main window to cull (not show) the world's visibility layer
	
	#_HomeWindow.set_canvas_cull_mask_bit(home_visibility_layer, true)
	#var new_window2: Window = view_window.instantiate()


	#new_window2.world_2d = _MainWindow.world_2d
	#new_window2.world_3d = _MainWindow.world_3d

	#new_window2.world_offset = world_offset

	#new_window2.set_canvas_cull_mask_bit(home_visibility_layer, false)
	#new_window2.set_canvas_cull_mask_bit(world_visibility_layer, true)
	#_HomeWindow = new_window2
	#add_child(new_window2)
	#
	##_HomeWindow.borderless = true		# Hide the edges of the window
	##_HomeWindow.unresizable = true		# Prevent resizing the window
	#_HomeWindow.always_on_top = true	# Force the window always be on top of the screen
	##_HomeWindow.gui_embed_subwindows = false # Make subwindows actual system windows <- VERY IMPORTANT
	##_HomeWindow.transparent = false		# Allow the window to be transparent
	##_HomeWindow.transparent_bg = true	# Make the window's background transparent
	#_HomeWindow.min_size = home_size * Vector2i(_HomeCamera.zoom) * 4
	#_HomeWindow.size = _HomeWindow.min_size
	#
	#
	#
	#_HomeWindow.set_canvas_cull_mask_bit(home_visibility_layer, true)
	_MainWindow.set_canvas_cull_mask_bit(player_visibility_layer, true)
	_MainWindow.set_canvas_cull_mask_bit(world_visibility_layer, false)
	# -------------------------------------------
	# Position the world at the bottom-center of the screen
	

	
	
	world_offset = Vector2i(_MainScreenRect.size.x / 2, _MainScreenRect.size.y)

var ttttt = true
func _process(delta):
	# Update the main window's position
	_MainWindow.position = get_window_pos_from_camera()
	if(ttttt):
		#_HomeWindow = creating_window.instantiate()
		_HomeWindow = create_view_window()
		_HomeWindow.min_size =home_size * Vector2i(_HomeCamera.zoom)
		_HomeWindow.size = _HomeWindow.min_size
#
		#_HomeWindow.world_2d = _HomeWindow.world_2d
		#_HomeWindow.world_3d = _HomeWindow.world_3d
		### The new window needs to have the same world offset as the player
		#_HomeWindow.world_offset = world_offset
		### Contrarily to the main window, hide the player and show the world
		#_HomeWindow.set_canvas_cull_mask_bit(home_visibility_layer, false)
		#_HomeWindow.set_canvas_cull_mask_bit(world_visibility_layer, true)
		#add_child(_HomeWindow)
		_HomeWindow.borderless = true
		
		ttttt = false
	_HomeWindow.position = get_window_pos_from_camera2()
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		create_view_window()
	
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func get_window_pos_from_camera()->Vector2i:
	return (Vector2i(_MainCamera.global_position + _MainCamera.offset) - player_size / 2) * Vector2i(_MainCamera.zoom) + world_offset
func get_window_pos_from_camera2()->Vector2i:
	return (Vector2i(_HomeCamera.global_position + _HomeCamera.offset) - home_size / 2) * Vector2i(_HomeCamera.zoom) + world_offset

func create_view_window()->Window:
	#var new_window: Window = view_window.instantiate()
	var new_window: Window = creating_window.instantiate()
	# Pass the main window's world to the new window
	# This is what makes it possible to show the same world in multiple windows
	new_window.world_2d = _MainWindow.world_2d
	new_window.world_3d = _MainWindow.world_3d
	# The new window needs to have the same world offset as the player
	new_window.world_offset = world_offset
	# Contrarily to the main window, hide the player and show the world
	new_window.set_canvas_cull_mask_bit(player_visibility_layer, false)
	new_window.set_canvas_cull_mask_bit(world_visibility_layer, true)
	add_child(new_window)
	return new_window
		
func _create_world_windowss():
	for sprite in sprite_array:
		print("creating new world windows")
		var new_world_window : Window = view_window.instantiate()
		new_world_window.position = sprite.global_position - (sprite.scale *  Vector2(59, 59)/2)
		new_world_window.size = sprite.scale * Vector2(59,59)
		
		new_world_window.world_2d = _MainWindow.world_2d
		new_world_window.world_3d = _MainWindow.world_3d
		
		add_child(new_world_window)
