extends ColorRect

var main_menu_scene : PackedScene = load("res://main_menu.tscn")
var hangman_scene : PackedScene = load("res://game/hang_man.tscn")
@onready var lobby_grid : VBoxContainer = $HBoxContainer/ColorRect/VBoxContainer/VBoxContainer
@onready var logs :Label = $HBoxContainer/ColorRect/VBoxContainer/Label
@onready var seal_button: Button = $HBoxContainer/ColorRect/VBoxContainer/HBoxContainer/Seal
@onready var start_button: Button = $HBoxContainer/ColorRect/VBoxContainer/HBoxContainer/Start
@onready var lobby_label = $HBoxContainer/ColorRect/VBoxContainer/PaddingTop/LabelLobbies
var container_peer_scene :PackedScene = preload("res://menus/lobby_viewer/container_peer.tscn")

var title := ""

func _on_button_main_menu_pressed() -> void:
	var result : LobbyResult = await GlobalLobbyClient.leave_lobby().finished
	if result.has_error():
		logs.text = result.error
	else:
		logs.text = "Left Succesfuly"
		await get_tree().create_timer(0.2).timeout
		get_tree().change_scene_to_packed(main_menu_scene)

func update_title():
	lobby_label.text = GlobalLobbyClient.lobby.lobby_name + " " + str(GlobalLobbyClient.lobby.players) + "/" + str(GlobalLobbyClient.lobby.max_players) + " " + str(GlobalLobbyClient.lobby.sealed)

func _ready() -> void:
	GlobalLobbyClient.peer_joined.connect(_peer_joined)
	GlobalLobbyClient.peer_left.connect(_peer_left)
	GlobalLobbyClient.lobby_left.connect(_lobby_left)
	GlobalLobbyClient.lobby_sealed.connect(_lobby_sealed)
	GlobalLobbyClient.received_data.connect(_lobby_data)
	if !GlobalLobbyClient.is_host():
		seal_button.visible = false
		start_button.visible = false
	update_title()
	for child in lobby_grid.get_children():
		child.queue_free()
	for peer in GlobalLobbyClient.peers:
		var peer_container := container_peer_scene.instantiate()
		peer_container.peer = peer
		peer_container.logs = logs
		lobby_grid.add_child(peer_container)

func _peer_joined(peer: LobbyPeer):
	update_title()
	var peer_container := container_peer_scene.instantiate()
	peer_container.peer = peer
	peer_container.logs = logs
	lobby_grid.add_child(peer_container)

func _peer_left(peer: LobbyPeer, _kicked: bool):
	update_title()
	for child in lobby_grid.get_children():
		if child.peer.id == peer.id:
			child.queue_free()

func _lobby_left():
	get_tree().change_scene_to_packed(main_menu_scene)

func _lobby_data(data: String, from_peer: String):
	if data == "start_game" && from_peer == GlobalLobbyClient.lobby.host:
		logs.text = "Starting Game"
		await get_tree().create_timer(0.2).timeout
		get_tree().change_scene_to_packed(hangman_scene)


func _on_ready_pressed() -> void:
	var result :LobbyResult = await GlobalLobbyClient.lobby_ready(!GlobalLobbyClient.peer.ready).finished
	if result.has_error():
		logs.text = result.error


func _on_seal_pressed() -> void:
	var result :LobbyResult = await GlobalLobbyClient.seal_lobby(!GlobalLobbyClient.lobby.sealed).finished
	if result.has_error():
		logs.text = result.error

func _lobby_sealed(_sealed: bool):
	update_title()

func _on_start_pressed() -> void:
	var result :LobbyResult = await GlobalLobbyClient.lobby_data("start_game").finished
	if result.has_error():
		logs.text = result.error
