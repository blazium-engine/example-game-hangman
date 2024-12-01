extends ColorRect

var main_menu_scene : PackedScene = load("res://main_menu.tscn")
var lobby_creator_scene : PackedScene = load("res://menus/lobby_creator.tscn")
@export var lobby_grid : VBoxContainer
@export var logs :Label
@export var page_label : Label
var container_lobby_scene :PackedScene = preload("res://menus/lobby_browser/container_lobby.tscn")

var page = 0

func _on_button_main_menu_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)

func _ready() -> void:
	load_lobbies()

func load_lobbies():
	var result : ListLobbyResult = await GlobalLobbyClient.list_lobby(page, 10).finished
	if result.has_error():
		logs.text = result.error
	for child in lobby_grid.get_children():
		child.queue_free()
	for lobby in result.lobbies:
		var lobby_container := container_lobby_scene.instantiate()
		lobby_container.lobby = lobby
		lobby_container.logs = logs
		lobby_grid.add_child(lobby_container)


func _on_refresh_button_pressed() -> void:
	load_lobbies()


func _on_left_pressed() -> void:
	page -= 1
	if page < 0:
		page = 0
	page_label.text = str(page + 1)
	load_lobbies()


func _on_right_pressed() -> void:
	page += 1
	page_label.text = str(page + 1)
	load_lobbies()


func _on_create_lobby_pressed() -> void:
	get_tree().change_scene_to_packed(lobby_creator_scene)
