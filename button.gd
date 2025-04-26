extends Button

var scene:PackedScene
@onready var rc: RayCast3D = $"../../../Node3D/Camera3D/RayCast3D"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("pressed",_on_pressed)
	scene = load("res://"+name+".tscn")

func _on_pressed():
	get_tree().call_group("temp","queue_free")
	rc.set_cube(scene)
