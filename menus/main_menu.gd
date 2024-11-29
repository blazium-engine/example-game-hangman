extends Control

var lobby_browser_scene : PackedScene = load("res://menus/lobby_browser/lobby_browser.tscn")
var lobby_creator_scene : PackedScene = load("res://menus/lobby_creator.tscn")
var reconnects = 0
@onready var lobby_connection_label : Label = $HBoxContainer2/ColorRect/VBoxContainer/VBoxContainer/VBoxContainer/Label

func _ready() -> void:
	GlobalLobbyClient.append_log.connect(_on_logs)
	GlobalLobbyClient.disconnected_from_lobby.connect(_on_disconnect)
	connect_to_lobby()

func connect_to_lobby():
	GlobalLobbyClient.server_url = "ws://localhost:8080/connect"
	var connected = GlobalLobbyClient.connect_to_lobby("Hangman")
	if connected:
		lobby_connection_label.text = "Lobby Service: Connected"

func _on_logs(command: String, logs:String):
	print(command, " ", logs)
	
func _on_disconnect():
	lobby_connection_label.text = "Lobby Service: Retrying"
	if reconnects > 5:
		push_error("Cannot connect")
		return
	reconnects += 1
	await get_tree().create_timer(0.5 * reconnects).timeout
	connect_to_lobby()

func _on_button_join_public_pressed() -> void:
	get_tree().change_scene_to_packed(lobby_browser_scene)


func _on_button_lobby_pressed() -> void:
	get_tree().change_scene_to_packed(lobby_creator_scene)


func _on_line_edit_text_submitted(new_text: String) -> void:
	var result :LobbyResult= await GlobalLobbyClient.set_peer_name(new_text).finished
	if result.has_error():
		push_error(result.error)
