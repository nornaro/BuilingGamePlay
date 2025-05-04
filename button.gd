extends TextureButton

var scene:PackedScene
@onready var rc: RayCast3D
var path:String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rc = get_tree().get_first_node_in_group("rc")
	connect("pressed",_on_pressed)
	scene = load(path)

func _on_pressed():
	get_tree().call_group("temp","queue_free")
	rc.set_cube(scene)
