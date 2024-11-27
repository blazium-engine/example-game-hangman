extends Control

var lobby_browser_scene : PackedScene = load("res://menus/lobby_browser.tscn")
var lobby_creator_scene : PackedScene = load("res://menus/lobby_creator.tscn")
@onready var lobby_connection_label : Label = $HBoxContainer2/ColorRect/VBoxContainer/VBoxContainer/VBoxContainer/Label
func _ready() -> void:
	GlobalLobbyClient.append_log.connect(_on_logs)
	GlobalLobbyClient.disconnected_from_lobby.connect(_on_disconnect)
	connect_to_lobby()

func connect_to_lobby():
	var connected = GlobalLobbyClient.connect_to_lobby("Hangman")
	if connected:
		lobby_connection_label.text = "Lobby Service: Connected"
	else:
		lobby_connection_label.text = "Lobby Service: Disconnected"

func _on_logs(command: String, logs:String):
	print(command, " ", logs)
	
func _on_disconnect():
	print("Disconnected")

func _on_button_join_public_pressed() -> void:
	get_tree().change_scene_to_packed(lobby_browser_scene)


func _on_button_lobby_pressed() -> void:
	get_tree().change_scene_to_packed(lobby_creator_scene)
