extends LobbyClient

var reconnects = 0
var game_id = "hangman"

func _ready() -> void:
	disconnected_from_lobby.connect(_on_disconnect)
	#GlobalLobbyClient.server_url = "ws://localhost:8080/connect"
	GlobalLobbyClient.connect_to_lobby(game_id)

func _on_disconnect():
	print("Disconnected")
	if reconnects > 50:
		push_error("Cannot connect")
		return
	reconnects += 1
	await get_tree().create_timer(0.5 * reconnects).timeout
	GlobalLobbyClient.connect_to_lobby(game_id)
