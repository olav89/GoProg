#
#
# Script for the player
#
#

extends KinematicBody

# Paths
const PATH_INGAME_MENU = "IngameMenu"
const PATH_HELP_MENU = "HelpMenu"
const PATH_SETTINGS_MENU = "Settings"
const PATH_SAMPLE_PLAYER = "SamplePlayer"
const PATH_CAMERA = "Camera"
const PATH_AREA = "Camera/Area"
const PATH_TUTORIAL = "Level11"

# Node references
var level = null
var gui = null
var sample_player = null

# Menus
var is_captured = true

# Collisions
var touchable_objects = []

# Physics
var gravity_direction = -1 # direction of the Y-component in gravity vector
const movement_speed = 10
var velocity = Vector3(0,0,0)
var jump_cd = 0

# Player rotation
var rot_current = 0
var rot_target = 0

# Camera
var view_sensitivity = 0.2
var yaw = 0
var pitch = 0

func setup(level, gui):
	self.level = level
	self.gui = gui

func _ready():
	set_process_input(true)
	set_process(true)
	set_fixed_process(true)
	sample_player = get_node(PATH_SAMPLE_PLAYER)

func _process(delta):
	if jump_cd > 0:
		jump_cd -= delta
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and !is_captured:
		is_captured = true
	elif Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE and is_captured:
		is_captured = false

# Function handles player movement and rotation
func _fixed_process(delta):
	var looking_at = get_node(PATH_CAMERA).get_global_transform().basis
	
	# Rotate player when gravity turns
	if gravity_direction == -1 and rot_current > 0:
		rot_target = 0
	elif gravity_direction == 1 and rot_current == 0:
		rot_target = 180
	if rot_current != rot_target:
		rot_current += 4*gravity_direction
		self.rotate(Vector3(1,0,0), deg2rad(4))

	# Player movement
	velocity.x = 0
	velocity.z = 0
	
	# Handle leg collision
	var is_ray_colliding = get_node("Leg").is_colliding()
	if is_ray_colliding: # if legs are on ground slide on it
		var n = get_node("Leg").get_collision_normal()
		velocity = n.slide(velocity)
	else: # else apply gravity
		velocity.y += delta * 9.8 * gravity_direction
	
	# Process all input
	if is_captured:
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
			velocity.y += -4*gravity_direction
			jump_cd = 2
	if velocity.z != 0 or velocity.x != 0:
		sample_player.play_sample_walking()
	# Lower speed if two directions are chosen
	if (Input.is_action_pressed("player_forward") and 
	(Input.is_action_pressed("player_right") or
	Input.is_action_pressed("player_left"))) or (
	Input.is_action_pressed("player_backward") and
	Input.is_action_pressed("player_right") or 
	Input.is_action_pressed("player_left")):
		velocity.x = velocity.x * movement_speed / 1.41
		velocity.z = velocity.z * movement_speed / 1.41
	else:
		velocity.x = velocity.x * movement_speed
		velocity.z = velocity.z * movement_speed

	# Move with velocity, slide if a collision is detected
	var motion = velocity * delta
	move(motion)
	if (is_colliding()):
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)

func _input(event):
	# Handles mouse movement
	if (event.type == InputEvent.MOUSE_MOTION) and is_captured:
		var motion = event.relative_pos
		yaw -= motion.x * view_sensitivity
		pitch += motion.y * view_sensitivity
		var e = 0.001
		if pitch > 90-e:
			pitch = 90-e
		elif pitch < -90+e:
			pitch = -90+e
		get_node(PATH_CAMERA).set_rotation(Vector3(0, deg2rad(yaw), 0))
		get_node(PATH_CAMERA).rotate_x(deg2rad(pitch))

	if (event.type == InputEvent.MOUSE_BUTTON):
		pass
	# Handles key events besides the player movement
	if (event.type == InputEvent.KEY) and is_captured:
		# Interactions
		if Input.is_action_pressed("interact"):
			var is_pc = false
			# Check for PC first:
			for obj in touchable_objects:
				if level.is_pc(obj):
					is_pc = true
					var pc = obj.get_node("../../..")
					level.pc_node = pc
					pc.get_screen()._show()
			if !is_pc:
				for obj in touchable_objects:
					if obj.has_method("player_interact"):
						obj.player_interact()
		
		
		# Code activation
		if Input.is_action_pressed("activate_code"):
			get_node("/root/execute").execute_code()
		


func is_player(body):
	if self.get_instance_ID() == body.get_instance_ID():
		return true
	return false

# Collision in front of player
func _on_Area_body_enter( body ):
	touchable_objects.append(body)
	if level == null:
		get_node("/root/logger").log_error("level undefined in player.gd")
	elif gui == null:
		get_node("/root/logger").log_error("gui undefined in player.gd")
	elif level.is_pc(body) or body.has_method("player_interact"):
		gui.change_notification("Interact: E", 2)

# Collision object no longer colliding
func _on_Area_body_exit( body ):
	touchable_objects.erase(body)