extends Control

var main_menu_scene : PackedScene = load("res://menus/main_menu.tscn")
@onready var 

func _on_button_main_menu_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)


func _on_check_box_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.
