extends Control

var main_menu_scene : PackedScene = load("res://main_menu.tscn")
var lobby_viewer_scene : PackedScene = load("res://menus/lobby_viewer.tscn")
@onready var password_line_edit :LineEdit = $HBoxContainer/ColorRect/VBoxContainer/VBoxContainer/HBoxContainerPrivacy/CheckButton
@onready var players_label : Label = $HBoxContainer/ColorRect/VBoxContainer/VBoxContainer/HBoxContainerPlayers/Label
@onready var logs : Label = $HBoxContainer/ColorRect/VBoxContainer/VBoxContainer/Logs

func _on_button_main_menu_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)


func _on_check_box_toggled(toggled_on: bool) -> void:
	password_line_edit.visible = toggled_on
	if !toggled_on:
		password_line_edit.text = ""


func _on_button_create_lobby_pressed() -> void:
	var result : CreateLobbyResult = await GlobalLobbyClient.create_lobby(int(players_label.text), password_line_edit.text).finished
	if result.has_error():
		logs.text = result.error
	else:
		logs.text = result.lobby_name
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_packed(lobby_viewer_scene)
