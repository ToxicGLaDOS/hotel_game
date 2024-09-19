extends Node2D

@export var guests: Array[PackedScene]
@export var front_desk_position: Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
    spawn()

func spawn():
    var guest_index = randi() % guests.size()
    var guest_scene = guests[guest_index]
    var guest = guest_scene.instantiate()
    guest.npc_json = preload("res://resources/npcs/guest.tres")

    add_child(guest)
    guest.set_target(front_desk_position.global_position)

