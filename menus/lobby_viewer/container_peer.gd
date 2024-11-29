extends Control

@onready var _peer_name: Label = $Label
@onready var _peer_ready: Label = $Ready
@onready var _kick_button: Button = $Button

@export var peer : LobbyPeer

func _ready():
	_peer_name.text = peer.peer_name
	_peer_ready.text = str(peer.ready)
	# If not host, hide kick button
	if GlobalLobbyClient.lobby.host != GlobalLobbyClient.peer.id:
		_kick_button.visible = false


func _on_button_pressed() -> void:
	var result : LobbyResult = await GlobalLobbyClient.kick_peer(peer.id).finished
	if result.has_error():
		push_error(result.error)
	else:
		print("Success")
