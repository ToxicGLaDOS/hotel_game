extends Node2D
class_name TileMapManager

@export var base: TileMap
@export var preview: TileMap

# Base TileMap layers
var floor_layer = 0
var object_layer = 1
var player_controlled_layer = 2
var transparent_layer = 3
# Preview layers
var preview_layer = 0

var base_object_tileset_id = 2
var preview_object_tileset_id = 0

func set_deletion_preview(tile_position: Vector2i) -> void:
    var tile_atlas_coords: Vector2i

    # Move everything from the transparent layer
    # back down to the player controller layer
    for used_cell in base.get_used_cells(transparent_layer):
        tile_atlas_coords = base.get_cell_atlas_coords(transparent_layer, used_cell)
        base.set_cell(player_controlled_layer, used_cell, base_object_tileset_id, tile_atlas_coords)
        base.erase_cell(transparent_layer, used_cell)

    # tile_atlas_coords is Vector2i(-1,-1) if the tile doesn't exist
    # which works fine with set_cell
    tile_atlas_coords = base.get_cell_atlas_coords(player_controlled_layer, tile_position)
    base.erase_cell(player_controlled_layer, tile_position)
    base.set_cell(transparent_layer, tile_position, base_object_tileset_id, tile_atlas_coords)

func set_placement_preview(tile_position: Vector2i, atlas_position: Vector2i) -> void:
    for used_cell in preview.get_used_cells(preview_layer):
        preview.erase_cell(preview_layer, used_cell)

    if can_place(tile_position):
        preview.set_cell(preview_layer, tile_position, preview_object_tileset_id, atlas_position)

func place_or_remove_tile(tile_position: Vector2i, atlas_position: Vector2i) -> void:
    if can_remove(tile_position):
        remove_tile(tile_position)
    elif can_place(tile_position):
        place_tile(tile_position, atlas_position)

func place_tile(tile_position: Vector2i, atlas_position: Vector2i) -> void:
    base.set_cell(player_controlled_layer, tile_position, base_object_tileset_id, atlas_position)

func remove_tile(tile_position: Vector2i) -> void:
    # This looks weird cause we're deleting off the transparent_layer
    # rather than the player_controlled_layer, but the deletion preview
    # puts stuff onto the transparent_layer
    base.erase_cell(transparent_layer, tile_position)

func can_remove(tile_position: Vector2i) -> bool:
    return base.get_cell_tile_data(transparent_layer, tile_position) != null

func can_place(tile_position: Vector2i) -> bool:
    var object_at_position = base.get_cell_tile_data(object_layer, tile_position)
    var player_controlled_at_position = base.get_cell_tile_data(object_layer, tile_position)
    return object_at_position == null and player_controlled_at_position == null
