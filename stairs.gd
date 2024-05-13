extends Area2D
class_name Stairs

@export var linked_stairs: Stairs
@export var navigation_link: NavigationLink2D
var transition_point: Node2D
var camera_point: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
    transition_point = linked_stairs.find_child("WarpPoint")
    camera_point = linked_stairs.find_child("CameraPoint")
    navigation_link = linked_stairs.find_child("NavigationLink2D")
    navigation_link.set_global_start_position(global_position)
    navigation_link.set_global_end_position(transition_point.global_position)
