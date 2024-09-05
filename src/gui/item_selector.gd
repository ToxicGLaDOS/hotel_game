extends MarginContainer
class_name ItemSelector

@export var selector: Panel
@export var hbox: HBoxContainer

var selected_item_index = 0
var tile_size = 16
# This is the position of the tile in the TileSet
# this assumes that the tile_size above is correct
# and the items in the selector are all the 1 tile big
var selected_tile_position = Vector2(0, 0)

func _ready():
    calculate_selected_tile_position()

func next_item():
    selected_item_index += 1
    selected_item_index = selected_item_index % hbox.get_child_count()

    move_selector()
    calculate_selected_tile_position()

func previous_item():
    selected_item_index -= 1
    selected_item_index = selected_item_index % hbox.get_child_count()

    move_selector()
    calculate_selected_tile_position()

func move_selector():
    var selected_item = hbox.get_child(selected_item_index)
    var selected_item_center = selected_item.global_position + selected_item.size / 2
    selector.global_position = selected_item_center - (selector.size / 2)

func calculate_selected_tile_position():
    var selected_item = hbox.get_child(selected_item_index)
    selected_tile_position = selected_item.texture.region.position / tile_size
