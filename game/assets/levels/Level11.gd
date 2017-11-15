#extends Spatial
extends "res://assets/levels_assets/defaultenvironment.gd"

var movedw = false
var moveds = false
var moveda = false
var movedd = false
var jumped = false
var looked = false
var tcheck1 = false
var pressj = false
var tcheck2 = false
var tcheck3 = false
var tcheck4 = false
var tcheck5 = false
var tcheck6 = false

func _ready():
	set_process_input(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_node("defaultenviroment/Player")._set_is_in_menu(true)
	
	# setup variables
	PATH_PAD = "Crate/VictoryPad"
	PATHS_AND_CODES_PC = [
	[DEFAULT + "PC",DEFAULT + "PC/PCScreen",
	["player.invert_gravity()",
	"room.invert_gravity()",
	"crate.move_left()",
	"crate.move_right()",
	"crate.move_forward()",
	"crate.move_backward()"]]
	]
	journal_text = "- Find the green button and press it.\n"
	journal_text += "- Interact with the PC by pressing E.\n"
	
	# setup scripts
	run_setup()

func _input(event):
	if (event.type == InputEvent.MOUSE_MOTION):
		looked = true

func _process(delta):
	if is_queued:
		var codes = PATHS_AND_CODES_PC[selection_pc][CODES]
		if selection_pc == 0 and queue_pos < selection.size():
			var code = selection[queue_pos]
			# gravity
			if code == codes[0]:
				gravity_direction_player *= -1
			elif code == codes[1]:
				gravity_direction_room *= -1
			# moving crate
			var move_dist = 4
			if code == codes[2]: # left
				get_node("Crate").set_target(Vector3(0,0,move_dist))
			elif code == codes[3]: # right
				get_node("Crate").set_target(Vector3(0,0,-move_dist))
			elif code == codes[4]: # forward
				get_node("Crate").set_target(Vector3(-move_dist,0,0))
			elif code == codes[5]: # backward
				get_node("Crate").set_target(Vector3(move_dist,0,0))
			is_queued = false
	
	if Input.is_action_pressed("player_forward"):
		movedw = true
	if Input.is_action_pressed("player_backward"):
		moveds = true
	if Input.is_action_pressed("player_right"):
		movedd = true
	if Input.is_action_pressed("player_left"):
		moveda = true
	if Input.is_action_pressed("player_jump"):
		jumped = true
	
	if(movedw and moveds and moveda and movedd and looked and jumped and not tcheck1):
		tcheck1 = true
		get_node("TutorialStartScreen")._show()
		get_node("TutorialStartScreen/Panel/lbl_welcome text").hide()
		get_node("TutorialStartScreen/Panel/lblGoJournal").show()
	
	if tcheck1 and Input.is_action_pressed("journal") and not tcheck2 and tcheck1:
		pressj = true
		tcheck2 = true
		get_node("TutorialStartScreen")._show()
		get_node("TutorialStartScreen/Panel/lblGoJournal").hide()
		get_node("TutorialStartScreen/Panel/lblGoPc").show()
	
	if get_node("defaultenviroment/Player").is_in_pc_screen and not tcheck3 and tcheck2 and tcheck1:
		tcheck3 = true
		get_node("TutorialStartScreen")._show()
		get_node("TutorialStartScreen/Panel/lblGoPc").hide()
		get_node("TutorialStartScreen/Panel/lblInPc").show()
	
	if tcheck3 and not get_node("defaultenviroment/Player").is_in_pc_screen and not tcheck4 and tcheck2 and tcheck1:
		tcheck4 = true
		get_node("TutorialStartScreen")._show()
		get_node("TutorialStartScreen/Panel/lblInPc").hide()
		get_node("TutorialStartScreen/Panel/lblExCode").show()
	
	if tcheck4 and Input.is_action_pressed("activate_code") and not tcheck5:
		tcheck5 = true
		get_node("TutorialStartScreen")._show()
		get_node("TutorialStartScreen/Panel/lblExCode").hide()
		get_node("TutorialStartScreen/Panel/lblFun").show()
	
	if tcheck5 and get_node("defaultenviroment/Player").level.is_level_won and not tcheck6:
		tcheck6 = true
		get_node("TutorialStartScreen")._show()
		get_node("TutorialStartScreen/Panel/lblFun").hide()
		get_node("TutorialStartScreen/Panel/lblWon").show()
		
		
	