extends Control

@onready var _peer_name: Label = $Label
@onready var _peer_ready: Label = $Ready
@onready var _kick_button: Button = $Button

@export var peer : LobbyPeer
@export var logs : Label

func _ready():
	GlobalLobbyClient.peer_ready.connect(_on_peer_ready)
	_peer_name.text = peer.user_data.get("name", "")
	_peer_ready.text = "Ready: " + str(peer.ready)
	# If not host, hide kick button
	if GlobalLobbyClient.lobby.host != GlobalLobbyClient.peer.id:
		_kick_button.visible = false


func _on_button_pressed() -> void:
	var result : LobbyResult = await GlobalLobbyClient.kick_peer(peer.id).finished
	if result.has_error():
		logs.text = result.error

func _on_peer_ready(updated_peer: LobbyPeer, p_ready: bool):
	if updated_peer.id == peer.id:
		_peer_ready.text = "Ready: " + str(p_ready)
