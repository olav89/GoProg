extends Spatial

# Meshes
onready var lights = [
get_node("Color1"),
get_node("Color2"),
get_node("Color3"),
get_node("Color4")]

# Colors (Default: Red, Green, Blue, White)
var colors = [
Color(255,0,0),
Color(0,255,0),
Color(0,0,255),
Color(255,255,255)
]

# Timer and yield
var blink_timer
var blink_id
signal blink_finished

func _ready():
	pass

# Changing colors
func set_color(id, color):
	if id >= 0 and id <= 3:
		colors[id] = color

# Override material and start timer
func blink(id):
	if id >= 0 and id <= 3:
		var mat = FixedMaterial.new()
		mat.set_parameter(FixedMaterial.PARAM_EMISSION, colors[id])
		lights[id].set_material_override(mat)
		blink_id = id
		if blink_timer == null:
			blink_timer = Timer.new()
			blink_timer.set_one_shot(true)
			blink_timer.connect("timeout", self, "blink_timeout")
			add_child(blink_timer)
		blink_timer.set_wait_time(1)
		blink_timer.start()
	else:
		blink_timeout()

# Remove overridden material
func blink_timeout():
	if blink_id != null and lights[blink_id].get_material_override() != null:
		lights[blink_id].set_material_override(null)
		blink_timer.set_wait_time(0.5) # start timer again to get pause between lights
		blink_timer.start()
	else:
		emit_signal("blink_finished")
