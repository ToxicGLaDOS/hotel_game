extends CharacterBody2D

@export var dialouge_box: DialougeBox
@export var interact_text: Array[String]
@export var nav_agent: NavigationAgent2D
@export var target: Node2D
@export var speed: float

func interact():
    dialouge_box.open()
    dialouge_box.set_text_series(interact_text)

func _ready():
    # call_deferred ensures that we wait until the
    # navigation server is ready before trying to
    # get a path to the target
    call_deferred("set_target")

func set_target():
    nav_agent.set_target_position(Vector2(552, -88))

func _physics_process(_delta):
    if nav_agent.is_navigation_finished():
        return

    var next_path_position: Vector2 = nav_agent.get_next_path_position()
    var new_velocity: Vector2 = global_position.direction_to(next_path_position) * speed
    velocity = new_velocity
    move_and_slide()

# --- SIGNALS ---
func _on_transition_trigger_area_entered(area: Area2D):
    if area is Stairs:
        position = area.transition_point.global_position
