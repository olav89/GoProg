extends MeshInstance

var animation_player = null

var level_node = null

func setup(level):
	level_node = level

func _ready():
	animation_player = get_node("Door/AnimationPlayer")

func _on_Area_body_enter( body ):
	if not animation_player.is_playing() and level_node.is_won():
		animation_player.play("openDoor")
		get_node("StaticBody/CollisionShape").translate(Vector3(0, 0, -200))
		# TODO! Make this a trigger if you can, simply translating it away is an ugly hack
