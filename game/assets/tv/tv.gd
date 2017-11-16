extends Quad


func _ready():
	#get_material_override().set_texture(FixedMaterial.PARAM_DIFFUSE, get_node("TextureFrame/Viewport").get_render_target_texture())
	var rtt = get_node("Viewport").get_render_target_texture()
	get_material_override().set_texture(FixedMaterial.PARAM_DIFFUSE,rtt) 