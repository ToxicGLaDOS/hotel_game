extends NavigationRegion2D
class_name Navigation

func bake_tile_map(tile_map: TileMap) -> void:
    var polygons = get_tile_map_polygons(tile_map)
    # This is the outline we drew in the editor
    var main_outline = navigation_polygon.get_outline(0)
    navigation_polygon.clear_outlines()
    var nav_data = NavigationMeshSourceGeometryData2D.new()
    # This needs to be first so we keep outline 0 as the main outline
    navigation_polygon.add_outline(main_outline)

    for polygon in polygons:
        nav_data.add_obstruction_outline(polygon)
    NavigationServer2D.bake_from_source_geometry_data_async(
            navigation_polygon, nav_data,
            _on_baking_completed
    )

# Taken from https://github.com/suumpmolk/godot-tile-map-nav-plugin/blob/main/addons/tile_map_nav_plugin/dock.gd
func get_tile_map_polygons(tile_map: TileMap) -> Array:
    var polygons = []
    var physics_layers = tile_map.tile_set.get_physics_layers_count()
    for layer in tile_map.get_layers_count():
        var cells = tile_map.get_used_cells(layer)
        for cell in cells:
            var tile_data = tile_map.get_cell_tile_data(layer, cell)
            if tile_data != null:
                var tile_pos = tile_map.to_global(tile_map.map_to_local(cell))
                for physics_layer in physics_layers:
                    for polygon_index in tile_data.get_collision_polygons_count(physics_layer):
                        var points = tile_data.get_collision_polygon_points(physics_layer, polygon_index)
                        var converted_points = []
                        for p in points:
                            converted_points.append(p + tile_pos)
                        polygons.append(converted_points)
    return polygons

func _on_baking_completed():
    NavigationServer2D.region_set_navigation_polygon(get_region_rid(), navigation_polygon)
    queue_redraw()
