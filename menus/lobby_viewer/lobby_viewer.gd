extends PanelContainer

var main_menu_scene : PackedScene = load("res://main_menu.tscn")
var container_peer_scene :PackedScene = preload("res://menus/lobby_viewer/container_peer.tscn")

## Replace this scene to change the game, but keep the whole lobby service system.
## After all, on start, Blazium Services are no longer used
## because the server/host moves to the player host.
@export var hangman_scene : PackedScene
@export var lobby_grid : VBoxContainer
@export var logs_label :Label
@export var seal_button: Button
@export var ready_button: Button
@export var start_button: Button
@export var lobby_label: Label
@export var chat_input: LineEdit
@export var chat_text : RichTextLabel
@export var left_spacer: Control
@export var right_spacer: Control

var title := ""

func _on_button_main_menu_pressed() -> void:
	var result : LobbyResult = await GlobalLobbyClient.leave_lobby().finished
	if result.has_error():
		logs_label.text = result.error

func update_title():
	lobby_label.text = GlobalLobbyClient.lobby.lobby_name + " " + str(GlobalLobbyClient.lobby.players) + "/" + str(GlobalLobbyClient.lobby.max_players)
	
	if GlobalLobbyClient.lobby.sealed:
		seal_button.text = "Unseal"
	else:
		seal_button.text = "Seal"

func is_everyone_ready():
	for peer in GlobalLobbyClient.peers:
		if !peer.ready:
			return false
	return true

func update_start_button():
	start_button.disabled = !is_everyone_ready()

func _ready() -> void:
	# Update tags
	update_start_button()
	update_ready_button(GlobalLobbyClient.peer.ready)
	GlobalLobbyClient.peer_joined.connect(_peer_joined)
	GlobalLobbyClient.peer_left.connect(_peer_left)
	GlobalLobbyClient.lobby_left.connect(_lobby_left)
	GlobalLobbyClient.lobby_sealed.connect(_lobby_sealed)
	GlobalLobbyClient.lobby_tagged.connect(_lobby_tagged)
	GlobalLobbyClient.peer_ready.connect(_peer_ready)
	GlobalLobbyClient.peer_messaged.connect(_peer_messaged)
	GlobalLobbyClient.disconnected_from_server.connect(_disconnected_from_server)
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
	_lobby_tagged.call_deferred(GlobalLobbyClient.lobby.tags)

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

func _peer_messaged(peer: LobbyPeer, chat_message: String):
	var message :String=  "[b]" + peer.user_data.get("name", "") + "[/b]: " + chat_message + "\n"
	chat_text.text += message

func _disconnected_from_server(_reason: String):
	if is_inside_tree():
		get_tree().change_scene_to_packed(main_menu_scene)

func _lobby_left(_kicked: bool):
	if is_inside_tree():
		get_tree().change_scene_to_packed(main_menu_scene)

## Once the host presses start, a message is sent to Blazium Services
## to add tags to the lobby via the `lobby_tagged` signal
## This signal is received by all players.
func _lobby_tagged(tags: Dictionary):
	if tags.get("game_state", "stopped") == "started":
		if is_inside_tree():
			get_tree().change_scene_to_packed(hangman_scene)

func update_ready_button(is_ready: bool):
	if is_ready:
		ready_button.text = "Unready"
	else:
		ready_button.text = "Ready"

func _on_ready_pressed() -> void:
	var new_ready := !GlobalLobbyClient.peer.ready
	var result :LobbyResult = await GlobalLobbyClient.set_lobby_ready(new_ready).finished
	if result.has_error():
		logs_label.text = result.error
	else:
		update_ready_button(new_ready)

func _on_seal_pressed() -> void:
	var result :LobbyResult = await GlobalLobbyClient.set_lobby_sealed(!GlobalLobbyClient.lobby.sealed).finished
	if result.has_error():
		logs_label.text = result.error

func _lobby_sealed(_sealed: bool):
	update_title()
	update_start_button()

func _on_start_pressed() -> void:
	# Triggers `_lobby_tagged()` function via signal for all players.
	var result :LobbyResult = await GlobalLobbyClient.add_lobby_tags({"game_state": "started"}).finished
	if result.has_error():
		logs_label.text = result.error


func _on_chat_button_pressed() -> void:
	if chat_input.text.is_empty():
		return
	var result :LobbyResult = await GlobalLobbyClient.send_chat_message(chat_input.text).finished
	if result.has_error():
		logs_label.text = result.error
	chat_input.clear()

func _on_chat_input_text_submitted(_new_text: String) -> void:
	_on_chat_button_pressed()


func _on_resized() -> void:
	var show_spacers = size.x > 600
	left_spacer.visible = show_spacers
	right_spacer.visible = show_spacers

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		_on_button_main_menu_pressed()
