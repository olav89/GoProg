extends "res://assets/levels_assets/defaultenvironment.gd"

var TEXT_TV
#math params
var inn_a
var inn_b

func _ready():
	# setup variables
	set_process(true)
	PATH_TV = DEFAULT + "Tv"
	PATH_PAD = "Crate/VictoryPad"
	PATH_CRATE = "Crate"
	PATHS_PC = [DEFAULT + "PC"]
	journal_text = "- Find the green button and press it.\n"
	journal_text += "- Interact with the PC by pressing E.\n"
	
	TEXT_TV = " a + b = 5 \n a>0 \n b>0 \n a= \n b= "
	get_node("defaultenviroment/Tv/Viewport/TextureFrame/Label").set_text(TEXT_TV)
	
	# setup scripts
	run_setup()

func set_text_tv(text):
	get_node("defaultenviroment/Tv/Viewport/TextureFrame/Label").set_text(text)
	
func set_a(inntext):
	var text = get_node("defaultenviroment/Tv/Viewport/TextureFrame/Label").get_text()
	var help = " a=" + str(inntext)
	text = text.replace(" a= ", help)
	set_text_tv(text)
	inn_a = inntext
	emit_signal("finished")
	
func set_b(inntext):
	var text = get_node("defaultenviroment/Tv/Viewport/TextureFrame/Label").get_text()
	var help = " b=" + str(inntext)
	text = text.replace(" b= ", help)
	set_text_tv(text)
	inn_b = inntext
	emit_signal("finished")

func _process(delta):
	if (inn_a != null and inn_b != null):
		var isfive = inn_a + inn_b
		if(isfive == 5):
			set_text_tv(get_node("defaultenviroment/Tv/Viewport/TextureFrame/Label").get_text() + " \n GREAT WORK! LVL WON!")
			won()
