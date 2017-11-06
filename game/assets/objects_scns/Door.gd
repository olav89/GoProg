extends Spatial

const PATH_LEVEL = "../"

var animation_player

func _ready():
	animation_player = get_node("AnimationPlayer")

func _on_Area_body_enter( body ):
	if get_node(PATH_LEVEL).is_player(body) and not animation_player.is_playing():
		animation_player.play("Open Door")
		get_node("SpatialSamplePlayer").play("ding")
