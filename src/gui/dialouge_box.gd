extends MarginContainer
class_name DialougeBox

@export var rich_text: RichTextLabel
@export var player: Player

var text_series: Array[String]
var current_text = 0
var on_close = Callable()

# This is to ensure that we don't open and close the dialouge
# in the same frame
var just_opened = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    if Input.is_action_just_pressed("interact") and not just_opened:
        # If we're on the last text in the series
        if current_text == len(text_series) - 1:
            close()
        elif current_text < len(text_series) - 1:
            current_text += 1
            rich_text.text = text_series[current_text]

    just_opened = false

func close():
    visible = false
    player.enable_player()
    # Empty Callables (like the default value) crash
    # when called, so this check is mandatory
    if on_close.is_valid():
        on_close.call()
    on_close = Callable()

# This defaults to an empty Callable
func open(_on_close = Callable()):
    visible = true
    just_opened = true
    player.disable_player()
    on_close = _on_close

func set_text_series(series: Array[String]):
    current_text = 0
    text_series = series
    rich_text.text = series[0]
