class_name QuitButton
extends Button


func _enter_tree() -> void:
	text = "Quit"
	var confirm_exit: ConfirmationDialog = ConfirmationDialog.new()
	confirm_exit.hide()
	confirm_exit.min_size = Vector2(320, 240)
	add_child(confirm_exit)
	var ok: Button = confirm_exit.get_ok_button()
	ok.text = "Yes"
	ok.pressed.connect(func() -> void: get_tree().quit())
	confirm_exit.get_cancel_button().text = "No"
	confirm_exit.add_theme_constant_override("buttons_min_width", 100)
	confirm_exit.add_theme_constant_override("buttons_min_height", 48)
	pressed.connect(func() -> void: confirm_exit.popup_centered())
