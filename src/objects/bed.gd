extends Node2D

var clean_sprite: Sprite2D
var messy_sprite: Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
    clean_sprite = find_child("Clean")
    messy_sprite = find_child("Messy")

func interact(_player: Player):
    clean()

func clean():
    messy_sprite.visible = false
    clean_sprite.visible = true

