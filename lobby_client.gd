extends LobbyClient

@export var reconnects = 0

func _ready() -> void:
	var config = ConfigFile.new()
	config.load("user://blazium.cfg")
	reconnection_token = config.get_value("LobbyClient", "reconnection_token", "")

	disconnected_from_server.connect(_disconnected_from_server)
	log_updated.connect(_on_log_updated)
	#server_url = "ws://localhost:8080/connect"
	connected_to_server.connect(_connected_to_server)
	connect_to_server()

func _on_log_updated(command: String, message: String):
	print(command, ": ", message)

func _connected_to_server(_peer: LobbyPeer, new_reconnection_token: String):
	reconnects = 0
	var config = ConfigFile.new()
	config.set_value("LobbyClient", "reconnection_token", new_reconnection_token)
	var err = config.save("user://blazium.cfg")
	if err != OK:
		push_error(error_string(err))

func _disconnected_from_server(reason: String):
	if reason == "Reconnect Close":
		reconnection_token = ""
	print("Disconnected. ", reason)
	if reconnects > 10:
		push_error("Cannot connect")
		return
	reconnects += 1
	if is_inside_tree():
		await get_tree().create_timer(0.2 * reconnects).timeout
	connect_to_server()
