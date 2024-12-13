extends PanelContainer

var main_menu_scene: PackedScene = load("res://main_menu.tscn")
@export var logs_label: Label
@export var name_label: LineEdit
@export var save_button: Button
@export var left_spacer: Control
@export var right_spacer: Control

func _ready() -> void:
	name_label.text = GlobalLobbyClient.peer.peer_name
	GlobalLobbyClient.disconnected_from_lobby.connect(_disconnected_from_lobby)

func _on_button_main_menu_pressed() -> void:
	if is_inside_tree():
		get_tree().change_scene_to_packed(main_menu_scene)

func _on_resized() -> void:
	var show_spacers = size.x > 600
	left_spacer.visible = show_spacers
	right_spacer.visible = show_spacers


func _on_name_text_changed(new_text: String) -> void:
	save_button.disabled = new_text == GlobalLobbyClient.peer.peer_name || new_text == ""


func _on_button_save_pressed() -> void:
	var result :LobbyResult= await GlobalLobbyClient.set_peer_name(name_label.text).finished
	if result.has_error():
		logs_label.text = result.error
		
	save_button.disabled = true


func _on_name_text_submitted(_new_text: String) -> void:
	_on_button_save_pressed()

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		_on_button_main_menu_pressed()

func _disconnected_from_lobby(_reason: String):
	if is_inside_tree():
		get_tree().change_scene_to_packed(main_menu_scene)


func _on_button_disconnect_pressed() -> void:
	GlobalLobbyClient.reconnection_token = ""
	GlobalLobbyClient.disconnect_from_lobby()
