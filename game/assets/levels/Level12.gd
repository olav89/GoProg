extends "res://assets/levels_assets/defaultenvironment.gd"

func _ready():
	# setup variables
	set_process(true)
	PATH_TV = "defaultenviroment/Tv"
	PATH_PAD = "Crate/VictoryPad"
	PATH_CRATE = "Crate"
	PATHS_PC = [DEFAULT + "PC"]
	journal_text = "- Find the green button and press it.\n"
	journal_text += "- Interact with the PC by pressing E.\n"
	
	# setup scripts
	run_setup()

func set_aa():
	get_lbl()
	emit_signal("finished")

func get_lbl():
	var text = get_node(PATH_TV).get_node("Viewport/TextureFrame/Label").get_text()
	print(text)
	emit_signal("finished")

	

