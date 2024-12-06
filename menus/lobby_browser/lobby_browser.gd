extends PanelContainer

@export var lobby_grid: VBoxContainer
@export var logs: Label
@export var page_label: Label
@export var left_button: Button
@export var right_button: Button
@export var left_spacer: Control
@export var right_spacer: Control

var main_menu_scene: PackedScene = load("res://main_menu.tscn")
var lobby_creator_scene: PackedScene = load("res://menus/lobby_creator.tscn")
var container_lobby_scene: PackedScene = preload("res://menus/lobby_browser/container_lobby.tscn")

var page: int = 0


func _on_button_main_menu_pressed() -> void:
	if is_inside_tree():
		get_tree().change_scene_to_packed(main_menu_scene)


func _ready() -> void:
	load_lobbies()


func load_lobbies() -> void:
	var result : ListLobbyResult = await GlobalLobbyClient.list_lobbies({}, page * 10, 10).finished
	if result.has_error():
		logs.text = result.error
	for child in lobby_grid.get_children():
		child.queue_free()
	for lobby in result.lobbies:
		var lobby_container := container_lobby_scene.instantiate()
		lobby_container.lobby = lobby
		lobby_container.logs = logs
		lobby_grid.add_child(lobby_container)
	right_button.disabled = result.lobbies.size() != 10
	left_button.disabled = page == 0


func _on_refresh_button_pressed() -> void:
	load_lobbies()


func _on_left_pressed() -> void:
	page = maxi(page - 1, 0)
	page_label.text = str(page + 1)
	load_lobbies()


func _on_right_pressed() -> void:
	page += 1
	page_label.text = str(page + 1)
	load_lobbies()


func _on_create_lobby_pressed() -> void:
	if is_inside_tree():
		get_tree().change_scene_to_packed(lobby_creator_scene)


func _on_resized() -> void:
	var show_spacers = size.x > 600
	left_spacer.visible = show_spacers
	right_spacer.visible = show_spacers

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		_on_button_main_menu_pressed()
