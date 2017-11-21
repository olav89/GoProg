extends Quad

signal finished

func _ready():
	#get_material_override().set_texture(FixedMaterial.PARAM_DIFFUSE, get_node("TextureFrame/Viewport").get_render_target_texture())
	var rtt = get_node("Viewport").get_render_target_texture()
	get_material_override().set_texture(FixedMaterial.PARAM_DIFFUSE,rtt) 

func set_a():
	var text = get_node("Viewport/TextureFrame/Label").get_text()
	print(text)
	emit_signal("finished")
