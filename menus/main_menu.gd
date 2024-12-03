extends PanelContainer

var lobby_browser_scene : PackedScene = load("res://menus/lobby_browser/lobby_browser.tscn")
var lobby_creator_scene : PackedScene = load("res://menus/lobby_creator.tscn")

@export var peer_name_line_edit : LineEdit
@export var logs : Label
@export var menu: VBoxContainer
@export var set_name_menu: VBoxContainer
@export var set_name_button: Button
@export var multiplayer_button: Button
@export var quit_margin: MarginContainer
@export var left_spacer: Control
@export var right_spacer: Control

func _ready() -> void:
	get_tree().get_root().set_min_size(Vector2i(1280, 720));
	peer_name_line_edit.text = GlobalLobbyClient.peer.peer_name
	menu.visible = GlobalLobbyClient.peer.peer_name != ""
	set_name_menu.visible = GlobalLobbyClient.peer.peer_name == ""
	if GlobalLobbyClient.peer.peer_name != "":
		logs.text = ""
	if not (OS.get_name() in ["Android", "iOS", "Web"]):
		quit_margin.show()
		quit_margin.add_child(QuitButton.new())

func _on_button_join_public_pressed() -> void:
	get_tree().change_scene_to_packed(lobby_browser_scene)


func _on_button_lobby_pressed() -> void:
	get_tree().change_scene_to_packed(lobby_creator_scene)


func _on_set_name_pressed() -> void:
	var result :LobbyResult= await GlobalLobbyClient.set_peer_name(peer_name_line_edit.text).finished
	if result.has_error():
		logs.text = result.error
	else:
		menu.visible = true
		set_name_menu.visible = false
		multiplayer_button.grab_focus()


func _on_line_edit_text_submitted(_new_text: String) -> void:
	_on_set_name_pressed()
	multiplayer_button.grab_focus()


func _on_line_edit_text_changed(new_text: String) -> void:
	set_name_button.disabled = new_text == ""


func _on_resized() -> void:
	var show_spacers = size.x > 600
	left_spacer.visible = show_spacers
	right_spacer.visible = show_spacers
