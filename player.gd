extends CharacterBody2D
class_name Player

@export var SPEED: float
@export var animation: AnimatedSprite2D
@export var interact_distance: int
@export var preview_tilemap: TileMap
@export var real_tilemap: TileMap
@export var camera: Camera2D
@export var item_selector: ItemSelector
enum directions {UP, RIGHT, DOWN, LEFT}
enum modes {DEFAULT, PLACING}

var facing = directions.UP
var player_enabled = true
var transparent_layer = 0
var tileset_source_id = 0
var input_mode = modes.DEFAULT


func _draw():
    draw_line(Vector2(0,0), get_interaction_point() - position , Color.RED, 1.0)
    if Input.is_action_pressed("interact"):
        draw_line(Vector2(0,0), facing_as_vector() * interact_distance, Color.GREEN, 1.0)

func _process(_delta):
    preview_tilemap.clear_layer(transparent_layer)

    if player_enabled:
        if input_mode == modes.PLACING:
            # Create the preview of the placement
            if can_place():
                preview_tilemap.set_cell(transparent_layer, preview_tilemap.local_to_map(get_interaction_point()), tileset_source_id, item_selector.selected_tile_position)
            if Input.is_action_just_pressed("next_item"):
                item_selector.next_item()
            if Input.is_action_just_pressed("previous_item"):
                item_selector.previous_item()

        if Input.is_action_just_pressed("set_placing_mode"):
            input_mode = modes.PLACING
            item_selector.visible = true

        if Input.is_action_just_pressed("set_default_mode"):
            input_mode = modes.DEFAULT
            item_selector.visible = false

        if Input.is_action_just_pressed("interact"):
            var space_state = get_world_2d().direct_space_state
            # use global coordinates, not local to node
            var query = PhysicsRayQueryParameters2D.create(position, position + facing_as_vector() * interact_distance)
            var result = space_state.intersect_ray(query)
            if result and result.collider.has_method("interact"):
                result.collider.interact()
            elif can_place() and input_mode == modes.PLACING:
                var player_interaction_layer = 2
                var tileset_id = 2
                var place_tile_position = real_tilemap.local_to_map(get_interaction_point())
                real_tilemap.set_cell(player_interaction_layer, place_tile_position, tileset_id, item_selector.selected_tile_position)

            # This is just for debug
            if Input.is_action_pressed("interact") or Input.is_action_just_released("interact"):
                queue_redraw()

func _physics_process(_delta):
    if player_enabled:
        var vertical = Input.get_axis("move_up", "move_down")
        if vertical:
            velocity.y = vertical * SPEED
        else:
            velocity.y = move_toward(velocity.y, 0, SPEED)

        # Get the input direction and handle the movement/deceleration.
        var direction = Input.get_axis("move_left", "move_right")
        if direction:
            velocity.x = direction * SPEED
        else:
            velocity.x = move_toward(velocity.x, 0, SPEED)

        if abs(velocity.x) > abs(velocity.y):
            if velocity.x > 0:
                facing = directions.RIGHT
                animation.animation = "walking_right"
            elif velocity.x < 0:
                facing = directions.LEFT
                animation.animation = "walking_left"
        elif abs(velocity.y) > abs(velocity.x):
            # Negative y is up
            if velocity.y > 0:
                facing = directions.DOWN
                animation.animation = "walking_down"
            elif velocity.y < 0:
                facing = directions.UP
                animation.animation = "walking_up"

        move_and_slide()

func can_place():
    var interaction_point = real_tilemap.local_to_map(get_interaction_point())
    var real_tile_data = real_tilemap.get_cell_tile_data(1, interaction_point)
    return real_tile_data == null

func get_interaction_point():
    var player_size = find_child("CollisionShape2D").shape.size
    var collision_position = find_child("CollisionShape2D").global_position

    var extra_length = 0
    if facing == directions.UP or facing == directions.DOWN:
        # 16 is the size of a tile in the tilemap
        # we use that so that we never place something
        # on top of ourselves
        extra_length = player_size.y / 2 + 16
    else:
        extra_length = player_size.x / 2 + 16
    return collision_position + facing_as_vector() * extra_length

func facing_as_vector():
    if facing == directions.UP:
        return Vector2(0, -1)
    elif facing == directions.RIGHT:
        return Vector2(1, 0)
    elif facing == directions.DOWN:
        return Vector2(0, 1)
    elif facing == directions.LEFT:
        return Vector2(-1, 0)

func enable_player():
    player_enabled = true

func disable_player():
    player_enabled = false


# --- SIGNALS ---
func _on_transition_trigger_area_entered(area: Area2D):
    if area is Stairs:
        print(area)
        print('warp to: ', area.transition_point.global_position)
        position = area.transition_point.global_position
        camera.position = area.camera_point.global_position
