extends Area2D
class_name Stairs

@export var linked_stairs: Stairs
var transition_point: Node2D
var camera_point: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
    transition_point = linked_stairs.find_child("WarpPoint")
    camera_point = linked_stairs.find_child("CameraPoint")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    pass
