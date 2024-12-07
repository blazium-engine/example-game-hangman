extends PanelContainer

var main_menu_scene: PackedScene = load("res://main_menu.tscn")
var lobby_viewer_scene: PackedScene = load("res://menus/lobby_viewer/lobby_viewer.tscn")
@export var password_line_edit: LineEdit
@export var logs_label: Label
@export var max_players_label: Label
@export var title_label: LineEdit
@export var create_button: Button
@export var left_spacer: Control
@export var right_spacer: Control


func _on_button_main_menu_pressed() -> void:
	if is_inside_tree():
		get_tree().change_scene_to_packed(main_menu_scene)


func _on_check_box_toggled(toggled_on: bool) -> void:
	password_line_edit.editable = toggled_on
	if !toggled_on:
		password_line_edit.text = ""


func _on_button_create_lobby_pressed() -> void:
	var result : ViewLobbyResult = await GlobalLobbyClient.create_lobby(title_label.text, {}, int(max_players_label.text), password_line_edit.text).finished
	if result.has_error():
		logs_label.text = result.error
	else:
		logs_label.text = ""
	if is_inside_tree():
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

func _on_title_text_submitted(_new_text: String) -> void:
	_on_button_create_lobby_pressed()
	
func _on_resized() -> void:
	var show_spacers = size.x > 600
	left_spacer.visible = show_spacers
	right_spacer.visible = show_spacers

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		_on_button_main_menu_pressed()
