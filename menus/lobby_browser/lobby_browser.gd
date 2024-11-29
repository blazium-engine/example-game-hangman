extends ColorRect

var main_menu_scene : PackedScene = load("res://main_menu.tscn")
@onready var lobby_grid : VBoxContainer = $HBoxContainer/ColorRect/VBoxContainer/VBoxContainer
@onready var logs :Label = $HBoxContainer/ColorRect/VBoxContainer/Label
var container_lobby_scene :PackedScene = preload("res://menus/lobby_browser/container_lobby.tscn")

func _on_button_main_menu_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)

func _ready() -> void:
	load_lobbies()

func load_lobbies():
	var result : ListLobbyResult = await GlobalLobbyClient.list_lobby(0, 10).finished
	if result.has_error():
		logs.text = result.error
	else:
		logs.text = "Success"
	for child in lobby_grid.get_children():
		child.queue_free()
	for lobby in result.lobbies:
		var lobby_container := container_lobby_scene.instantiate()
		lobby_container.lobby_id = lobby.id
		lobby_container.lobby = lobby.name
		lobby_container.players = str(lobby.players) + "/" + str(lobby.max_players)
		lobby_grid.add_child(lobby_container)
		


func _on_refresh_button_pressed() -> void:
	load_lobbies()
