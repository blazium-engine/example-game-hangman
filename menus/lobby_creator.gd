extends Control

var main_menu_scene : PackedScene = load("res://main_menu.tscn")
var lobby_viewer_scene : PackedScene = load("res://menus/lobby_viewer/lobby_viewer.tscn")
@export var password_line_edit :LineEdit
@export var logs_label : Label
@export var max_players_label : Label
@export var title_label : LineEdit
@export var create_button: Button

func _on_button_main_menu_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)


func _on_check_box_toggled(toggled_on: bool) -> void:
	password_line_edit.visible = toggled_on
	if !toggled_on:
		password_line_edit.text = ""


func _on_button_create_lobby_pressed() -> void:
	var result : ViewLobbyResult = await GlobalLobbyClient.create_lobby(title_label.text, int(max_players_label.text), password_line_edit.text).finished
	if result.has_error():
		logs_label.text = result.error
	else:
		logs_label.text = ""
	get_tree().change_scene_to_packed(lobby_viewer_scene)


func _on_button_increment_pressed() -> void:
	var players := int(max_players_label.text)
	players += 1
	if players > 10:
		players = 10
	max_players_label.text = str(players)


func _on_button_decrement_pressed() -> void:
	var players := int(max_players_label.text)
	players -= 1
	if players < 1:
		players = 1
	max_players_label.text = str(players)


func _on_title_text_changed(new_text: String) -> void:
	create_button.disabled = new_text == ""
	if create_button.disabled:
		logs_label.text = "Title is required"
	else:
		logs_label.text = ""
