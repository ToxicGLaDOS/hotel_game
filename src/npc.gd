extends CharacterBody2D
class_name NPC

@export var speed: float
@export var npc_json: JSON
var interacting = false
var dialouge_box: DialougeBox
var nav_agent: NavigationAgent2D
var npc_data: Dictionary
var interact_text: Array[String]

func interact(player: Player):
    dialouge_box.open(end_interaction)
    dialouge_box.set_text_series(interact_text)
    interacting = true

func _ready():
    # TOOD: I don't like getting nodes by name, but
    # this is probably fine for now
    dialouge_box = get_node("/root/Root/CanvasLayer/DialogueBox")
    nav_agent = find_child("NavigationAgent2D")
    npc_data = npc_json.data
    # Functions as a cast to Array[String] from Array
    var dialogue: Array[String]
    dialogue.assign(npc_data["dialogue"])

    interact_text = dialogue

func end_interaction():
    interacting = false

func set_target(dest: Vector2):
    # dest is a global position
    nav_agent.set_target_position(dest)

func _physics_process(_delta):
    if not interacting:
        if nav_agent.is_navigation_finished():
            return

        var next_path_position: Vector2 = nav_agent.get_next_path_position()
        var new_velocity: Vector2 = global_position.direction_to(next_path_position) * speed
        velocity = new_velocity
        move_and_slide()

# --- SIGNALS ---
func _on_transition_trigger_area_entered(area: Area2D):
    if area is RoomLink:
        position = area.transition_point.global_position
