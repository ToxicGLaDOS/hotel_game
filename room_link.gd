extends Area2D
class_name RoomLink


enum LinkType {STAIR, DOOR}

@export var link: RoomLink
@export var navigation_link: NavigationLink2D
@export var link_type: LinkType
var transition_point: Node2D
var camera_point: Node2D


func _ready():
    transition_point = link.find_child("WarpPoint")
    camera_point = link.find_child("CameraPoint")
    navigation_link = link.find_child("NavigationLink2D")
    navigation_link.set_global_start_position(global_position)
    navigation_link.set_global_end_position(transition_point.global_position)
