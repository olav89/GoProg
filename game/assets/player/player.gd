#
# Script for the player
#
#

extends KinematicBody

var PATH_STATUS_BAR = "StatusBar"
var PATH_STATUS_BAR_TO_LABEL = "Label" # path relative to StatusBar node
var PATH_PC_TO_SCREEN = "PCScreen" # path relative to pc node
var PATH_INGAME_MENU = "IngameMenu"
var PATH_SAMPLE_PLAYER = "SamplePlayer"

var is_in_menu = false
var is_in_pc_screen = false

var level_node = null

var victory_pad_node = null
var victory_pad_is_interactable = false

var pc_is_interactable = false
var pc_node = null # the active pc node 
var pc_near_node = null # the nearest pc node

var status_bar = null # link to the status bar
var status_bar_time_remaining = 0
var STATUS_INTERACT = "Press E to interact"
var STATUS_INTERACT_TIME = 1
var STATUS_ACTIVATE = "Press F to activate your code"
var STATUS_ACTIVATE_TIME = 2
var STATUS_WON = "Proceed to the elevator"
var STATUS_WON_TIME = 15

var sample_player = null
var id_voice_walking = 0

var gravity_direction = -1 # direction of the Y-component in gravity vector

var view_sensitivity = 0.2
var yaw = 0
var pitch = 0
var movement_speed = 10
var velocity = Vector3(0,0,0)
var jump_cd = 0

func setup(level, victory_pad):
	level_node = level
	victory_pad_node = victory_pad

func _ready():
	set_process_input(true)
	set_process(true)
	set_fixed_process(true)
	status_bar = get_node(PATH_STATUS_BAR)
	sample_player = get_node(PATH_SAMPLE_PLAYER)

func _process(delta):
	if jump_cd > 0:
		jump_cd -= delta
	if status_bar_time_remaining > 0:
		status_bar_time_remaining -= delta
	elif not status_bar.is_hidden():
		status_bar.hide()
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		is_in_menu = false
		is_in_pc_screen = false

# Function handles player movement
func _fixed_process(delta):
	var looking_at = get_global_transform().basis
	velocity.x = 0
	velocity.z = 0
	velocity.y += delta * 9.8 * gravity_direction
	
	if not is_in_menu and not is_in_pc_screen:
		if Input.is_action_pressed("player_forward"):
			velocity.x -= looking_at[2].x
			velocity.z -= looking_at[2].z
		if Input.is_action_pressed("player_backward"):
			velocity.x += looking_at[2].x
			velocity.z += looking_at[2].z
		if Input.is_action_pressed("player_left"):
			velocity.x -= looking_at[0].x
			velocity.z -= looking_at[0].z
		if Input.is_action_pressed("player_right"):
			velocity.x += looking_at[0].x
			velocity.z += looking_at[0].z
		if Input.is_action_pressed("player_jump") and jump_cd <= 0:
			velocity.y += -6*gravity_direction
			jump_cd = 2
	if velocity.z != 0 or velocity.x != 0:
		play_sample_walking()
	velocity.x = velocity.x * movement_speed
	velocity.z = velocity.z * movement_speed

	var motion = velocity * delta
	move(motion)
	if (is_colliding()):
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)

func _input(event):
	# Handles mouse movement
	if (event.type == InputEvent.MOUSE_MOTION) and not is_in_menu and not is_in_pc_screen:
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
		if is_in_menu:
			if Input.is_action_pressed("ingame_menu"):
				get_node(PATH_INGAME_MENU)._hide()
		else:
			if Input.is_action_pressed("interact") and victory_pad_is_interactable:
				level_node.won()
				change_status(STATUS_WON, STATUS_WON_TIME)
			elif Input.is_action_pressed("interact") and pc_is_interactable:
				pc_node = pc_near_node # last pc close to player
				pc_node.get_node(PATH_PC_TO_SCREEN)._show()
				is_in_pc_screen = true
			elif Input.is_action_pressed("activate_code"):
				# Sends a notification to the scripts which are affected by an execute of selected code
				get_tree().call_group(0, "execute_code_group", "execute_code")
			elif Input.is_action_pressed("ingame_menu") and not is_in_pc_screen:
				get_node(PATH_INGAME_MENU)._show()
				is_in_menu = true

func change_status(text, time):
	status_bar.get_node(PATH_STATUS_BAR_TO_LABEL).set_text(text)
	status_bar.show()
	status_bar_time_remaining = time

func change_status_activate():
	change_status(STATUS_ACTIVATE, STATUS_ACTIVATE_TIME)

func play_sample_walking():
	if !sample_player.is_voice_active(id_voice_walking):
		id_voice_walking = sample_player.play("walking")
func play_sample_typing():
	sample_player.play("typing")

# Collision in front of player
func _on_Area_body_enter( body ):
	var body_id = body.get_instance_ID()
	var node = get_node("../PC/StaticBody")
	if node != null and body_id == node.get_instance_ID():
		pc_near_node = get_node("../PC")
		change_status(STATUS_INTERACT, STATUS_INTERACT_TIME)
		pc_is_interactable = true

# Collision object no longer colliding
func _on_Area_body_exit( body ):
	var body_id = body.get_instance_ID()
	var node = get_node("../PC/StaticBody")
	if node != null and body_id == node.get_instance_ID():
		pc_is_interactable = false

func _on_Area_area_enter( area ):
	if area.get_instance_ID() == victory_pad_node.get_instance_ID():
		victory_pad_is_interactable = true
		change_status(STATUS_INTERACT, STATUS_INTERACT_TIME)

func _on_Area_area_exit( area ):
	if area.get_instance_ID() == victory_pad_node.get_instance_ID():
		victory_pad_is_interactable = false
