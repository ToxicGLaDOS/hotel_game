extends CharacterBody2D
class_name Player

@export var SPEED: float
@export var animation: AnimatedSprite2D
@export var interact_distance: int
enum directions {UP, RIGHT, DOWN, LEFT}

var facing = directions.UP
var player_disabled = true


func _draw():
    if Input.is_action_pressed("interact"):
        draw_line(Vector2(0,0), Vector2(interact_distance,0), Color.GREEN, 1.0)

func _physics_process(_delta):
    if player_disabled:
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

        if Input.is_action_just_pressed("interact"):
            var space_state = get_world_2d().direct_space_state
            # use global coordinates, not local to node
            var query = PhysicsRayQueryParameters2D.create(position, position + Vector2(interact_distance, 0))
            var result = space_state.intersect_ray(query)
            if result and result.collider.has_method("interact"):
                result.collider.interact()

        # This is just for debug
        if Input.is_action_pressed("interact") or Input.is_action_just_released("interact"):
            queue_redraw()

        move_and_slide()

func enable_player():
    player_disabled = true

func disable_player():
    player_disabled = false
