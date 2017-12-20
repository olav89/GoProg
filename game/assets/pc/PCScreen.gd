# Script for the PC screen

extends Control

# Paths
const PATH_BUTTON_CONTAINER = "Panel/CodeBtn"
const PATH_EDITOR = "Panel/Editor"
const PATH_DEBUG = "Panel/Debug"
const PATH_HELP_GROUP = "Panel/btnHelpGroup"
const PATH_HELP_DETAIL_LBL = "Panel/HelpDetail/lblHelpDetail"
const PATH_HELP_DETAIL_BTN = "Panel/HelpDetail/btnHelpDetail"
var buttons = []

# Ref to gui node
var gui = null

# Timer for focus on editor
var focus_timer

func setup(gui_node, help_buttons, pre_text = ""):
	gui = gui_node
	for help in help_buttons: # add help buttons
		var b = Button.new()
		b.set_text(help[0])
		b.connect("pressed", self, "help_pressed", [b, help])
		get_node(PATH_HELP_GROUP).add_child(b)
	
	# Move camera to PC
	get_node("Panel/Control/Viewport/Camera").set_translation(get_node("../../PC").get_translation())
	get_node("Panel/Control/Viewport/Camera").translate(Vector3(0,2,0))
	
	if pre_text != "":
		set_editor_text(pre_text)

func _ready():
	get_node(PATH_EDITOR).set_wrap(true)
	get_node(PATH_DEBUG).set_readonly(true)

# Inverts PC Screen
func _invert():
	if get_pos() == Vector2(0,0):
		set_rotation(deg2rad(180))
		set_pos(Vector2(1024, 600))
	else:
		set_rotation(deg2rad(0))
		set_pos(Vector2(0,0))

# Event handler for pressing help buttons
func help_pressed(b, help):
	var lbl = get_node(PATH_HELP_DETAIL_LBL)
	var btn_group = get_node(PATH_HELP_DETAIL_BTN)
	for btn in btn_group.get_children():
		btn.queue_free()
	
	var description = help[1]
	var buttons = help[2]
	lbl.set_text(description)
	for btn_string in buttons:
		var b = Button.new()
		b.set_text(btn_string)
		b.connect("pressed", self, "help_detail_pressed", [b, btn_string])
		btn_group.add_child(b)

func help_detail_pressed(b, text):
	get_node(PATH_EDITOR).insert_text_at_cursor(text + "\n")

# Gets editor text in an array
func get_editor_text():
	var res = []
	var count = get_node(PATH_EDITOR).get_line_count()
	for i in range(count):
		var line = get_node(PATH_EDITOR).get_line(i)
		if line.length() > 0:
			res.append(line)
		else:
			res.append("")
	return res

# Gets editor text in a string
func get_editor_text_plain():
	return get_node(PATH_EDITOR).get_text()

# Set editor text
func set_editor_text(s):
	get_node(PATH_EDITOR).set_text(s)

# Set editor debug text
func set_editor_debug_text(s):
	get_node(PATH_DEBUG).set_text(s)

# Custom show function
func _show():
	show() 
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_node("/root/logger").log_debug("PC Screen active")
	
	# Focus timer is used to give focus to editor but not fill it with input from accessing pc
	if focus_timer == null:
		focus_timer = Timer.new()
		focus_timer.connect("timeout",self,"editor_grab_focus")
		focus_timer.set_one_shot(true)
		add_child(focus_timer)
	focus_timer.set_wait_time(0.5)
	focus_timer.start()

# Grab focus
func editor_grab_focus():
	get_node(PATH_EDITOR).grab_focus()

# Custom hide function
func _hide():
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_node("/root/logger").log_debug("PC Screen inactive")

# Event for the Enter button (exit screen)
func _on_btnEnter_pressed():
	_hide()
	if gui != null:
		gui.change_notification("Activate Code: F", 5)
	else:
		get_node("/root/logger").log_error("gui undefined in PCScreen.gd")

# Event for the Clear button
func _on_btnClear_pressed():
	get_node(PATH_EDITOR).set_text("")
	get_node("/root/logger").log_debug("PC Screen clear")
	editor_grab_focus()

# Event for build button
func _on_btnBuild_pressed():
	get_tree().call_group(0, "execute_code_group", "fix_code") # get errors in code

# Event for execute button
func _on_btnExecute_pressed():
	get_node("/root/execute").execute_code() # attempt to execute code
