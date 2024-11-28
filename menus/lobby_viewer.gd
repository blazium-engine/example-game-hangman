extends ColorRect

var main_menu_scene : PackedScene = load("res://main_menu.tscn")
@onready var lobby_grid : VBoxContainer = $HBoxContainer/ColorRect/VBoxContainer/VBoxContainer
@onready var logs :Label = $HBoxContainer/ColorRect/VBoxContainer/Label
@onready var lobby_label = $HBoxContainer/ColorRect/VBoxContainer/PaddingTop/LabelLobbies

func _on_button_main_menu_pressed() -> void:
	var result : LobbyResult = await GlobalLobbyClient.leave_lobby().finished
	if result.has_error():
		logs.text = result.error
	else:
		logs.text = "Left Succesfuly"
		await get_tree().create_timer(0.2).timeout
		get_tree().change_scene_to_packed(main_menu_scene)

func _ready() -> void:
	var lobby_name = GlobalLobbyClient.lobby_name
	var result : ViewLobbyResult = await GlobalLobbyClient.view_lobby(lobby_name).finished
	if result.has_error():
		logs.text = result.error
	else:
		logs.text = "Success"
	lobby_label.text = lobby_name
	for child in lobby_grid.get_children():
		child.queue_free()
	for lobby in result.peers:
		pass
		#var lobby_container := container_lobby_scene.instantiate()
		#lobby_container.lobby = lobby
		#lobby_grid.add_child(lobby_container)
		
