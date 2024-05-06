extends CharacterBody2D
class_name Player

@export var SPEED: float
@export var animation: AnimatedSprite2D
@export var interact_distance: int
@export var preview_tilemap: TileMap
@export var real_tilemap: TileMap
enum directions {UP, RIGHT, DOWN, LEFT}

var facing = directions.UP
var player_enabled = true
var transparent_layer = 0
var tileset_source_id = 0


func _draw():
    draw_line(Vector2(0,0), get_interaction_point() - position , Color.GREEN, 1.0)
    if Input.is_action_pressed("interact"):
        draw_line(Vector2(0,0), facing_as_vector() * interact_distance, Color.GREEN, 1.0)

func _process(_delta):
    preview_tilemap.clear_layer(transparent_layer)
    preview_tilemap.set_cell(transparent_layer, preview_tilemap.local_to_map(get_interaction_point()), tileset_source_id, Vector2i(0,2))
    if player_enabled:
        if Input.is_action_just_pressed("interact"):
            var space_state = get_world_2d().direct_space_state
            # use global coordinates, not local to node
            var query = PhysicsRayQueryParameters2D.create(position, position + facing_as_vector() * interact_distance)
            var result = space_state.intersect_ray(query)
            if result and result.collider.has_method("interact"):
                result.collider.interact()
            else:
                var player_interaction_layer = 2
                var tileset_id = 2
                var place_tile_position = real_tilemap.local_to_map(get_interaction_point())
                real_tilemap.set_cell(player_interaction_layer, place_tile_position, tileset_id, Vector2i(0,2))

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

func get_interaction_point():
    var player_size = find_child("CollisionShape2D").shape.size
    var extra_length = 0
    if facing == directions.UP or facing == directions.DOWN:
        # 16 is the size of a tile in the tilemap
        # we use that so that we never place something
        # on top of ourselves
        extra_length = player_size.y / 2 + 16
    else:
        extra_length = player_size.x / 2 + 16
    return position + facing_as_vector() * extra_length

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
