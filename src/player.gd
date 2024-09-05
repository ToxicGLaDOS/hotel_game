extends CharacterBody2D
class_name Player

@export var SPEED: float
@export var animation: AnimatedSprite2D
@export var raycast: RayCast2D
@export var tile_map_manager: TileMapManager
@export var camera: Camera2D
@export var item_selector: ItemSelector
enum directions {UP, RIGHT, DOWN, LEFT}
enum modes {DEFAULT, PLACING}

var facing = directions.UP
var player_enabled = true
var input_mode = modes.DEFAULT
var interact_distance: float

func _ready():
    interact_distance = (raycast.target_position - raycast.position).length()

func _draw():
    draw_line(Vector2(0,0), get_interaction_point() - position , Color.RED, 1.0)
    if Input.is_action_pressed("interact"):
        draw_line(Vector2(0,0), facing_as_vector() * interact_distance, Color.GREEN, 1.0)

func _process(_delta):
    var tile_interaction_point = tile_map_manager.base.local_to_map(get_interaction_point())
    var selected_item = item_selector.selected_tile_position
    if player_enabled:
        if input_mode == modes.PLACING:
            tile_map_manager.set_deletion_preview(tile_interaction_point)
            tile_map_manager.set_placement_preview(tile_interaction_point, selected_item)

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
            tile_map_manager.clear_preview_layer()

        if Input.is_action_just_pressed("interact"):
            # It's not clear to me if get_collider is supposed to
            # be called from _physics_process, but I don't think so
            var collider = raycast.get_collider()
            if collider and collider.has_method("interact"):
                collider.interact(self)
            elif input_mode == modes.PLACING:
                tile_map_manager.place_or_remove_tile(tile_interaction_point, selected_item)

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
        var horizontal = Input.get_axis("move_left", "move_right")
        if horizontal:
            velocity.x = horizontal * SPEED
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

        raycast.target_position = facing_as_vector() * interact_distance

        move_and_slide()


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

func move_rooms(new_position, new_camera_position):
    position = new_position
    camera.position = new_camera_position

# --- SIGNALS ---
func _on_transition_trigger_area_entered(area: Area2D):
    if area is RoomLink and area.link_type == RoomLink.LinkType.STAIR:
        move_rooms(area.transition_point.global_position, area.camera_point.global_position)
