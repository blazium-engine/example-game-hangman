extends Control

var lobby_viewer_scene : PackedScene = load("res://menus/lobby_viewer/lobby_viewer.tscn")
@onready var _lobby_name: Label = $Label
@onready var _lobby_players: Label = $LabelPlayers
@onready var _password : LineEdit = $LineEdit

@export var lobby :LobbyInfo
@export var logs: Label

func _ready():
	_lobby_name.text = lobby.lobby_name
	_lobby_players.text = str(lobby.players) + "/" + str(lobby.max_players)


func _on_button_pressed() -> void:
	var result : ViewLobbyResult = await GlobalLobbyClient.join_lobby(lobby.id, _password.text).finished
	if result.has_error():
		logs.text = result.error
	else:
		get_tree().change_scene_to_packed(lobby_viewer_scene)
