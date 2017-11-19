
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
var jcheck = false
var jcheck2 = false

func set_jcheck(set):
	jcheck = set
func set_jcheck2(set):
	jcheck2 = set
	
func _ready():
	set_process_input(true)
	set_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_node("defaultenviroment/Player")._set_is_in_menu(true)
	
	# setup variables
	PATH_PAD = "Crate/VictoryPad"
	PATH_CRATE = "Crate"
	PATHS_PC = [DEFAULT + "PC"]
	
	# setup scripts
	run_setup()

	journal_text = "- Find the green button and press it.\n"
	journal_text += "- Interact with the PC by pressing E.\n"
	

func _input(event):
	if (event.type == InputEvent.MOUSE_MOTION):
		looked = true

func _process(delta):
	if Input.is_action_pressed("player_forward")and jcheck2:
		movedw = true
	if Input.is_action_pressed("player_backward")and jcheck2:
		moveds = true
	if Input.is_action_pressed("player_right")and jcheck2:
		movedd = true
	if Input.is_action_pressed("player_left")and jcheck2:
		moveda = true
	if Input.is_action_pressed("player_jump")and jcheck2:
		jumped = true
	
	if(movedw and moveds and moveda and jcheck2 and movedd and looked and jumped and not tcheck1):
		tcheck1 = true
		get_node("TutorialStartScreen")._show()
		get_node("TutorialStartScreen/Panel/lbl_welcome text").hide()
		get_node("TutorialStartScreen/Panel/lblGoJournal").show()
			
	if tcheck1 and Input.is_action_pressed("journal") and jcheck and not tcheck2 and tcheck1:
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
