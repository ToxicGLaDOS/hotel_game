extends MarginContainer
class_name DialougeBox

@export var rich_text: RichTextLabel
@export var player: Player

var text_series: Array[String]
var current_text = 0

# This is to ensure that we don't open and close the dialouge
# in the same frame
var just_opened = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    if Input.is_action_just_pressed("interact") and not just_opened:
        # If we're on the last text in the series
        if current_text == len(text_series) - 1:
            close()
        else:
            current_text += 1
            rich_text.text = text_series[current_text]

    just_opened = false

func close():
    visible = false
    player.enable_player()

func open():
    visible = true
    just_opened = true
    player.disable_player()

func set_text_series(series: Array[String]):
    current_text = 0
    text_series = series
    rich_text.text = series[0]
