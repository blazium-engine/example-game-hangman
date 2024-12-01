extends ColorRect

var main_menu_scene : PackedScene = load("res://main_menu.tscn")
var hangman_scene : PackedScene = load("res://game/hang_man.tscn")
var container_peer_scene :PackedScene = preload("res://menus/lobby_viewer/container_peer.tscn")
@export var lobby_grid : VBoxContainer
@export var logs_label :Label
@export var seal_button: Button
@export var start_button: Button
@export var lobby_label: Label
@export var chat_input: LineEdit
@export var chat_text : RichTextLabel

var title := ""

func _on_button_main_menu_pressed() -> void:
	var result : LobbyResult = await GlobalLobbyClient.leave_lobby().finished
	if result.has_error():
		logs_label.text = result.error

func update_title():
	lobby_label.text = GlobalLobbyClient.lobby.lobby_name + " " + str(GlobalLobbyClient.lobby.players) + "/" + str(GlobalLobbyClient.lobby.max_players) + " Sealed: " + str(GlobalLobbyClient.lobby.sealed)

func is_everyone_ready():
	for peer in GlobalLobbyClient.peers:
		if !peer.ready:
			return false
	return true

func update_start_button():
	start_button.disabled = !is_everyone_ready() || !GlobalLobbyClient.lobby.sealed

func _ready() -> void:
	update_start_button()
	GlobalLobbyClient.peer_joined.connect(_peer_joined)
	GlobalLobbyClient.peer_left.connect(_peer_left)
	GlobalLobbyClient.lobby_left.connect(_lobby_left)
	GlobalLobbyClient.lobby_sealed.connect(_lobby_sealed)
	GlobalLobbyClient.received_data.connect(_lobby_data)
	GlobalLobbyClient.peer_ready.connect(_peer_ready)
	GlobalLobbyClient.disconnected_from_lobby.connect(_disconnected_from_lobby)
	if !GlobalLobbyClient.is_host():
		seal_button.visible = false
		start_button.visible = false
	update_title()
	for child in lobby_grid.get_children():
		child.queue_free()
	for peer in GlobalLobbyClient.peers:
		var peer_container := container_peer_scene.instantiate()
		peer_container.peer = peer
		peer_container.logs = logs_label
		lobby_grid.add_child(peer_container)

func _peer_joined(peer: LobbyPeer):
	var peer_container := container_peer_scene.instantiate()
	peer_container.peer = peer
	peer_container.logs = logs_label
	lobby_grid.add_child(peer_container)
	update_title()
	update_start_button()

func _peer_left(peer: LobbyPeer, _kicked: bool):
	for child in lobby_grid.get_children():
		if child.peer.id == peer.id:
			child.queue_free()
	update_title()
	update_start_button()

func _peer_ready(_peer: LobbyPeer, _p_ready: bool):
	update_start_button()

func _disconnected_from_lobby():
	get_tree().change_scene_to_packed(main_menu_scene)

func _lobby_left():
	get_tree().change_scene_to_packed(main_menu_scene)

func _lobby_data(data: Dictionary, from_peer: LobbyPeer):
	match data["command"]:
		"start_game":
			if from_peer.id == GlobalLobbyClient.lobby.host:
				get_tree().change_scene_to_packed(hangman_scene)
		"send_chat":
			if from_peer.id != GlobalLobbyClient.lobby.host || GlobalLobbyClient.is_host():
				var message :String=  "[b]" + from_peer.peer_name + "[/b]: " + data["data"] + "\n"
				var result :LobbyResult = await GlobalLobbyClient.lobby_data({"command": "receive_chat", "data": message }).finished
				if result.has_error():
					logs_label.text = result.error
		"receive_chat":
			chat_text.text += data["data"]

func _on_ready_pressed() -> void:
	var result :LobbyResult = await GlobalLobbyClient.lobby_ready(!GlobalLobbyClient.peer.ready).finished
	if result.has_error():
		logs_label.text = result.error


func _on_seal_pressed() -> void:
	var result :LobbyResult = await GlobalLobbyClient.seal_lobby(!GlobalLobbyClient.lobby.sealed).finished
	if result.has_error():
		logs_label.text = result.error

func _lobby_sealed(_sealed: bool):
	update_title()
	update_start_button()

func _on_start_pressed() -> void:
	var result :LobbyResult = await GlobalLobbyClient.lobby_data({"command": "start_game"}).finished
	if result.has_error():
		logs_label.text = result.error


func _on_chat_button_pressed() -> void:
	if chat_input.text.is_empty():
		return
	var result :LobbyResult = await GlobalLobbyClient.lobby_data({"command": "send_chat", "data": chat_input.text }).finished
	if result.has_error():
		logs_label.text = result.error
	chat_input.clear()



func _on_chat_input_text_submitted(new_text: String) -> void:
	_on_chat_button_pressed()
