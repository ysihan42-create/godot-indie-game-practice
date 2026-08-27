extends Control


@onready var start_button: Button = $Buttons/StartButton
@onready var quit_button: Button = $Buttons/QuitButton


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
