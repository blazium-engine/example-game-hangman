extends ColorRect

var main_menu_scene : PackedScene = load("res://main_menu.tscn")
@onready var lobby_grid : VBoxContainer = $HBoxContainer/ColorRect/VBoxContainer/VBoxContainer
@onready var logs :Label = $HBoxContainer/ColorRect/VBoxContainer/Label
@onready var lobby_label = $HBoxContainer/ColorRect/VBoxContainer/PaddingTop/LabelLobbies
var container_peer_scene :PackedScene = preload("res://menus/lobby_viewer/container_peer.tscn")

var players := 0
var max_players := 0
var title := ""

func _on_button_main_menu_pressed() -> void:
	var result : LobbyResult = await GlobalLobbyClient.leave_lobby().finished
	if result.has_error():
		logs.text = result.error
	else:
		logs.text = "Left Succesfuly"
		await get_tree().create_timer(0.2).timeout
		get_tree().change_scene_to_packed(main_menu_scene)

func _ready() -> void:
	GlobalLobbyClient.peer_joined.connect(_peer_joined)
	GlobalLobbyClient.peer_left.connect(_peer_left)
	GlobalLobbyClient.lobby_left.connect(_lobby_left)
	var lobby_id = GlobalLobbyClient.lobby.id
	var result : ViewLobbyResult = await GlobalLobbyClient.view_lobby(lobby_id).finished
	if result.has_error():
		logs.text = result.error
	else:
		logs.text = "Success"
	players = result.peers.size()
	max_players = result.lobby.max_players
	title = result.lobby.lobby_name
	lobby_label.text = title + " " + str(players) + "/" + str(max_players)
	for child in lobby_grid.get_children():
		child.queue_free()
	for peer in result.peers:
		var peer_container := container_peer_scene.instantiate()
		peer_container.peer = peer
		lobby_grid.add_child(peer_container)

func _peer_joined(peer: LobbyPeer):
	players += 1
	lobby_label.text = title + " " + str(players) + "/" + str(max_players)
	var peer_container := container_peer_scene.instantiate()
	peer_container.peer = peer
	lobby_grid.add_child(peer_container)

func _peer_left(peer: LobbyPeer, kicked: bool):
	players -= 1
	lobby_label.text = title + " " + str(players) + "/" + str(max_players)
	for child in lobby_grid.get_children():
		if child.peer.id == peer.id:
			child.queue_free()

func _lobby_left():
	get_tree().change_scene_to_packed(main_menu_scene)
