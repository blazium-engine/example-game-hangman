extends ColorRect

var main_menu_scene : PackedScene = load("res://menus/main_menu.tscn")

func _on_button_main_menu_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)
