extends PanelContainer

@export var lobby_grid: VBoxContainer
@export var logs: Label
@export var left_spacer: Control
@export var right_spacer: Control

var main_menu_scene: PackedScene = load("res://main_menu.tscn")
var lobby_creator_scene: PackedScene = load("res://menus/lobby_creator.tscn")
var container_lobby_scene: PackedScene = preload("res://menus/lobby_browser/container_lobby.tscn")

func _on_button_main_menu_pressed() -> void:
	if is_inside_tree():
		get_tree().change_scene_to_packed(main_menu_scene)


func _ready() -> void:
	GlobalLobbyClient.disconnected_from_lobby.connect(_disconnected_from_lobby)
	GlobalLobbyClient.lobbies_listed.connect(_lobbies_listed)
	var result :LobbyResult = await GlobalLobbyClient.list_lobbies().finished
	if result.has_error():
		logs.text = result.error


func _lobbies_listed(lobbies: Array[LobbyInfo]) -> void:
	for child in lobby_grid.get_children():
		child.queue_free()
	for lobby in lobbies:
		var lobby_container := container_lobby_scene.instantiate()
		lobby_container.lobby = lobby
		lobby_container.logs = logs
		lobby_grid.add_child(lobby_container)

func _on_create_lobby_pressed() -> void:
	if is_inside_tree():
		get_tree().change_scene_to_packed(lobby_creator_scene)


func _on_resized() -> void:
	var show_spacers = size.x > 600
	left_spacer.visible = show_spacers
	right_spacer.visible = show_spacers

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		_on_button_main_menu_pressed()

func _disconnected_from_lobby(_reason: String):
	if is_inside_tree():
		get_tree().change_scene_to_packed(main_menu_scene)
