extends CharacterBody2D

@export var dialouge_box: DialougeBox
@export var interact_text: Array[String]

func interact():
	dialouge_box.open()
	dialouge_box.set_text_series(interact_text)


