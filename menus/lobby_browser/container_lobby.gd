extends Control

var lobby_viewer_scene : PackedScene = load("res://menus/lobby_viewer/lobby_viewer.tscn")
@onready var _lobby_name: Label = $Label
@onready var _lobby_players: Label = $LabelPlayers

@export var lobby_id := ""
@export var lobby := ""
@export var players := ""

func _ready():
	_lobby_name.text = lobby
	_lobby_players.text = players


func _on_button_pressed() -> void:
	var result : LobbyResult = await GlobalLobbyClient.join_lobby(lobby_id).finished
	if result.has_error():
		push_error(result.error)
	else:
		get_tree().change_scene_to_packed(lobby_viewer_scene)
