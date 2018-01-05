extends "res://assets/levels_assets/defaultenvironment.gd"

var TEXT_TV
#math params
var inn_a
var inn_b

func _ready():
	# setup variables
	set_process(true)
	PATH_TV = DEFAULT + "Tv"
	PATH_CRATE = "Crate"
	journal_text = "- Solve Math on Wall.\n"
	journal_text += "- Interact with the PC by pressing E.\n"
	
	TEXT_TV = " a + b = 5 \n a>0 \n b>0 \n a= \n b= "
	get_node("defaultenviroment/Tv/Viewport/TextureFrame/Label").set_text(TEXT_TV)
	editor_text = """
# use set_a(?) and set_b(?) and exchange the ? with your answers for a and b 
# press either build and then exit the computer and rund the code with f-button 
# or just hit the execute button
	
set_a(?)
set_b(?)
	"""
	
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
