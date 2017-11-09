#
# Script for the player
#
#

extends KinematicBody

# Paths
const PATH_STATUS_BAR = "StatusBar"
const PATH_INGAME_MENU = "IngameMenu"
const PATH_HELP_MENU = "HelpMenu"
const PATH_SETTINGS_MENU = "Settings"
const PATH_SAMPLE_PLAYER = "SamplePlayer"
const PATH_CAMERA = "Camera"
const PATH_AREA = "Camera/Area"
const PATH_JOURNAL = "Journal"

# Node references
var level = null
var journal = null
var sample_player = null
var status_bar = null

# Menus
var is_in_menu = false
var is_in_pc_screen = false

# Victory Pad
var victory_pad_is_interactable = false

# PC Interaction
var pc_is_interactable = false
var pc_node = null # the active pc node 
var pc_near_node = null # the nearest pc node
var pc_near_node_col = 0 # counts collisions with pc components
var activation_cd = 0 # cooldown to activate code

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

func setup(level, journal_text):
	self.level = level
	journal.change_journal(journal_text)

func _ready():
	set_process_input(true)
	set_process(true)
	set_fixed_process(true)
	status_bar = get_node(PATH_STATUS_BAR)
	sample_player = get_node(PATH_SAMPLE_PLAYER)
	journal = get_node(PATH_JOURNAL)

func _process(delta):
	if jump_cd > 0:
		jump_cd -= delta
	if activation_cd > 0:
		activation_cd -= delta
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		is_in_menu = false
		is_in_pc_screen = false

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
	if (event.type == InputEvent.MOUSE_MOTION) and not is_in_menu and not is_in_pc_screen:
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
		get_node("../Door/AnimationPlayer").play("Open Door")
		get_node("../Door1/AnimationPlayer").play("Open Door")
	# Handles key events besides the player movement
	if (event.type == InputEvent.KEY):
		if is_in_menu: # Controls while in menu
			if Input.is_action_pressed("ingame_menu"):
				get_node(PATH_INGAME_MENU)._hide()
				get_node(PATH_HELP_MENU)._hide()
				get_node(PATH_SETTINGS_MENU)._hide()
		else: # Ingame controls
			# Journal
			if Input.is_action_pressed("journal"):
				if journal.is_hidden():
					journal.show()
				else:
					journal.hide()
			
			# Interactions
			if Input.is_action_pressed("interact") and victory_pad_is_interactable:
				if level != null:
					level.won()
					status_bar.change_status_won()
					get_node("/root/logger").log_info("Player has won.")
					saveGame()
				else:
					get_node("/root/logger").log_error("level not defined in player.gd")
			elif Input.is_action_pressed("interact") and pc_is_interactable:
				pc_node = pc_near_node # last pc close to player
				pc_node.get_screen()._show()
				is_in_pc_screen = true
			elif Input.is_action_pressed("interact"):
				# Calls a method in all colliding objects
				# Note that this call will go to the collision object
				for obj in touchable_objects:
					if obj.has_method("player_interact"):
						obj.player_interact()
			
			# Code activation
			if Input.is_action_pressed("activate_code") and activation_cd <= 0:
				# Sends a notification to the scripts which are affected by an execute of selected code
				get_tree().call_group(0, "execute_code_group", "execute_code")
				get_node("/root/logger").log_debug("Executing code")
				activation_cd = 1.5
			
			# Open menu
			if Input.is_action_pressed("ingame_menu") and not is_in_pc_screen:
				get_node(PATH_INGAME_MENU)._show()
				is_in_menu = true

func is_player(body):
	if self.get_instance_ID() == body.get_instance_ID():
		return true
	return false

# Collision in front of player
func _on_Area_body_enter( body ):
	if level == null:
		get_node("/root/logger").log_error("level undefined in player.gd")
	elif level.is_pc(body):
		pc_near_node_col += 1
		pc_near_node = body.get_node("../../..") # go up three levels as collisions are nested
		status_bar.change_status_interact()
		pc_is_interactable = true
		get_node("/root/logger").log_debug("PC in range")
	else:
		touchable_objects.append(body)

# Collision object no longer colliding
func _on_Area_body_exit( body ):
	if level == null:
		get_node("/root/logger").log_error("level undefined in player.gd")
	elif level.is_pc(body):
		pc_near_node_col -= 1
		if pc_near_node_col == 0:
			pc_is_interactable = false
			get_node("/root/logger").log_debug("PC out of range")
	else:
		touchable_objects.erase(body)

func _on_Area_area_enter( area ):
	if level == null:
		get_node("/root/logger").log_error("level undefined in player.gd")
	elif level.is_victory_pad(area):
		victory_pad_is_interactable = true
		status_bar.change_status_interact()
		get_node("/root/logger").log_debug("Pad in range")

func _on_Area_area_exit( area ):
	if level == null:
		get_node("/root/logger").log_error("level undefined in player.gd")
	elif level.is_victory_pad(area):
		victory_pad_is_interactable = false
		get_node("/root/logger").log_debug("Pad out of range")

#saves name of solved lvl to file 
func saveGame():
	var savegame = File.new()
	savegame.open("user://savegame.save",File.WRITE)
	var currlvl= get_parent().get_parent().get_name().substr(5,1)
	var savestr = level_node.get_name() + "\n"
	savegame.store_line(savestr)
	savegame.close()
	get_node("/root/logger").log_info("Game Saved")

