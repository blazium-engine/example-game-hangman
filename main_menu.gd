extends PanelContainer

var lobby_browser_scene : PackedScene = preload("res://menus/lobby_browser/lobby_browser.tscn")
var lobby_creator_scene : PackedScene = preload("res://menus/lobby_creator.tscn")
var settings_scene : PackedScene = preload("res://menus/settings.tscn")

@export var peer_name_line_edit : LineEdit
@export var name_label: Label
@export var logs : Label
@export var menu: VBoxContainer
@export var set_name_menu: VBoxContainer
@export var set_name_button: Button
@export var multiplayer_button: Button
@export var quit_button: Button
@export var left_spacer: Control
@export var right_spacer: Control

var confirm_exit: ConfirmationDialog

func _ready() -> void:
	GlobalLobbyClient.log_updated.connect(_log_updated)
	_connected_to_lobby(GlobalLobbyClient.peer, "")
	GlobalLobbyClient.connected_to_lobby.connect(_connected_to_lobby)
	if not (OS.get_name() in ["Android", "iOS", "Web"]):
		quit_button.show()
		create_quit_dialog()

func _connected_to_lobby(peer: LobbyPeer, _reconnection_token: String):
	name_label.visible = peer.user_data.get("name", "") != ""
	name_label.text = "Hello, " + peer.user_data.get("name", "")
	peer_name_line_edit.text = peer.user_data.get("name", "")
	menu.visible = peer.user_data.get("name", "") != ""
	set_name_menu.visible = peer.user_data.get("name", "") == ""
	if peer.user_data.get("name", "") != "":
		logs.text = ""

	# Don't show name menu on android and ios
	if peer.user_data.get("name", "") != "" or OS.has_feature("web_android") or OS.has_feature("web_ios") or OS.has_feature("android") or OS.has_feature("ios"):
		menu.visible = true
		set_name_menu.visible = false
		multiplayer_button.grab_focus()
	else:
		menu.visible = false
		set_name_menu.visible = true
	logs.text = ""

func _log_updated(command: String, logs_text: String):
	if command == "error":
		logs.text = command + " " + logs_text

func _on_button_join_public_pressed() -> void:
	if is_inside_tree():
		get_tree().change_scene_to_packed(lobby_browser_scene)


func _on_button_lobby_pressed() -> void:
	if is_inside_tree():
		get_tree().change_scene_to_packed(lobby_creator_scene)


func _on_set_name_pressed() -> void:
	var result :LobbyResult= await GlobalLobbyClient.add_peer_user_data({"name": peer_name_line_edit.text}).finished
	if result.has_error():
		logs.text = result.error
	else:
		menu.visible = true
		set_name_menu.visible = false
		name_label.visible = true
		name_label.text = "Hello, " + peer_name_line_edit.text
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


func _on_button_settings_pressed() -> void:
	if is_inside_tree():
		get_tree().change_scene_to_packed(settings_scene)


func create_quit_dialog():
	confirm_exit = ConfirmationDialog.new()
	confirm_exit.dialog_text = "Are you sure you want to exit?"
	confirm_exit.hide()
	confirm_exit.min_size = Vector2(240, 128)
	add_child(confirm_exit)
	var ok: Button = confirm_exit.get_ok_button()
	ok.text = "Yes"
	ok.pressed.connect(func(): get_tree().quit())
	confirm_exit.get_cancel_button().text = "No"
	confirm_exit.add_theme_constant_override("buttons_min_width", 100)
	confirm_exit.add_theme_constant_override("buttons_min_height", 48)


func _on_quit_button_pressed() -> void:
	confirm_exit.popup_centered()


func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		_on_quit_button_pressed()
