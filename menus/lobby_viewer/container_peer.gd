extends Control

@onready var _peer_name: Label = $Label
@onready var _peer_ready: Label = $Ready

@export var peer_id := ""
@export var peer := ""
@export var ready_text := ""

func _ready():
	_peer_name.text = peer
	_peer_ready.text = ready_text


func _on_button_pressed() -> void:
	var result : LobbyResult = await GlobalLobbyClient.kick_peer(peer_id).finished
	if result.has_error():
		push_error(result.error)
	else:
		print("Success")
