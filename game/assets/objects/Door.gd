extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func open():
	get_node("AnimationPlayer").play("open")
	get_node("SpatialSamplePlayer").play("ding")