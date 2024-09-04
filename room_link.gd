extends Area2D
class_name RoomLink


enum LinkType {STAIR, DOOR}

@export var link: RoomLink
@export var navigation_link: NavigationLink2D
@export var link_type: LinkType
var transition_point: Node2D
var camera_point: Node2D


func _ready():
    var warp_point = find_child("WarpPoint")
    transition_point = link.find_child("WarpPoint")
    camera_point = link.find_child("CameraPoint")
    navigation_link = link.find_child("NavigationLink2D")
    # NPCs should move right to stairs
    if link_type == LinkType.STAIR:
        navigation_link.set_global_start_position(global_position)
    # but to the entry/exit point of doors
    else:
        navigation_link.set_global_start_position(warp_point.global_position)
    navigation_link.set_global_end_position(transition_point.global_position)
