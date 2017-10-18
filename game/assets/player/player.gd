#
# Script for the player
#
#

extends KinematicBody

var PATH_STATUS_BAR = "StatusBar"
var PATH_STATUS_BAR_TO_LABEL = "Label" # path relative to StatusBar node
var PATH_PC_TO_SCREEN = "PCScreen" # path relative to pc node
var PATH_INGAME_MENU = "IngameMenu"

var status_bar_time_remaining = 0

var pc_is_interactable = false
var pc_node = null # the active pc node 
var pc_near_node = null # the nearest pc node

var status_bar = null # link to the status bar

var gravity_direction = -1 # direction of the Y-component in gravity vector

var view_sensitivity = 0.2
var yaw = 0
var pitch = 0
var movement_speed = 10
var velocity = null

func _ready():
	set_process_input(true)
	set_process(true)
	set_fixed_process(true)
	status_bar = get_node(PATH_STATUS_BAR)

func _process(delta):
	if status_bar_time_remaining > 0:
		status_bar_time_remaining -= delta
	elif not status_bar.is_hidden():
		status_bar.hide()
	# Disable processes if a menu is open
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE and is_processing_input():
		set_process_input(false)
		set_fixed_process(false)
	# Enable processes if menus were closed
	elif Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and !is_processing_input():
		set_process_input(true)
		set_fixed_process(true)

# Function handles player movement
func _fixed_process(delta):
	var looking_at = get_global_transform().basis
	velocity = Vector3(0,0,0)
	velocity.y += delta * 200 * gravity_direction
	
	if Input.is_action_pressed("player_forward"):
		velocity -= looking_at[2]
	if Input.is_action_pressed("player_backward"):
		velocity += looking_at[2]
	if Input.is_action_pressed("player_left"):
		velocity -= looking_at[0]
	if Input.is_action_pressed("player_right"):
		velocity += looking_at[0]
	
	velocity = velocity * movement_speed

	var motion = velocity * delta
	move(motion)
	if (is_colliding()):
        var n = get_collision_normal()
        motion = n.slide(motion)
        velocity = n.slide(velocity)
        move(motion)

func _input(event):
	# Handles mouse movement
	if (event.type == InputEvent.MOUSE_MOTION):
		var motion = event.relative_pos

		yaw -= motion.x * view_sensitivity
		pitch += motion.y * view_sensitivity

		var e = 0.001
		if pitch > 90-e:
			pitch = 90-e
		elif pitch < -90+e:
			pitch = -90+e
		set_rotation(Vector3(0, deg2rad(yaw), 0))
		rotate_x(deg2rad(pitch))
	
	if (event.type == InputEvent.MOUSE_BUTTON):
		pass
	# Handles key events besides the player movement
	if (event.type == InputEvent.KEY):
		if Input.is_action_pressed("interact") and pc_is_interactable:
			pc_node = pc_near_node # last pc close to player
			pc_node.get_node(PATH_PC_TO_SCREEN).show()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif Input.is_action_pressed("activate_code"):
			# Sends a notification to the scripts which are affected by an execute of selected code
			get_tree().call_group(0, "execute_code_group", "execute_code")
		elif Input.is_action_pressed("ingame_menu"):
			get_node(PATH_INGAME_MENU).show()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Collision in front of player
func _on_Area_body_enter( body ):
	var body_id = body.get_instance_ID()
	var node = get_node("../PC/StaticBody")
	if node != null and body_id == node.get_instance_ID():
		pc_near_node = get_node("../PC")
		change_status("Press E to use the computer.", 2)
		pc_is_interactable = true

# Collision object no longer colliding
func _on_Area_body_exit( body ):
	var body_id = body.get_instance_ID()
	var node = get_node("../PC/StaticBody")
	if node != null and body_id == node.get_instance_ID():
		pc_is_interactable = false

func change_status(text, time):
	status_bar.get_node(PATH_STATUS_BAR_TO_LABEL).set_text(text)
	status_bar.show()
	status_bar_time_remaining = time