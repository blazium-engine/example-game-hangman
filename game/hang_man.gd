extends Node

@export var head: ColorRect
@export var body: ColorRect
@export var leftArm: ColorRect
@export var rightArm: ColorRect
@export var leftLeg: ColorRect
@export var rightLeg: ColorRect
@export var set_word_button: Button
@export var letter_pad: LetterPad
@export var logs: Label

var main_menu_scene : PackedScene = load("res://main_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalLobbyClient.received_data.connect(_received_data)
	GlobalLobbyClient.lobby_left.connect(_lobby_left)
	GlobalLobbyClient.append_log.connect(_append_log)
	# Host sets the word initially
	if !GlobalLobbyClient.is_host():
		set_buttons_enabled(false)
		set_word_button.visible = false

func find_node_by_name(parent: Node, p_name: String) -> Node:
	# Check if the current parent node matches the name
	if parent.name == p_name:
		return parent

	# Iterate through all children of the current parent node
	for child in parent.get_children():
		# Recursively search in each child
		var found_node = find_node_by_name(child, p_name)
		if found_node:
			return found_node

	# If not found, return null
	return null

func set_buttons_enabled(enabled: bool):
	for i in 26:
		var letter = char(i + 65)
		var node :Button= find_node_by_name(self, "Button" + letter)
		node.disabled = !enabled

func _received_data(data: Dictionary, from_peer: String):
		match data["command"]:
			"count":
				# Only host can set word length
				if from_peer == GlobalLobbyClient.lobby.host:
					# Disable host input until peers guess the word
					if GlobalLobbyClient.is_host():
						set_buttons_enabled(false)
						set_word_button.disabled = true
						return
					set_buttons_enabled(true)
					var count = data["count"]
					letter_pad.set_length(count)
			"guess":
				var guess = data["letter"]
				# Only peers can guess, this only calls on the host
				if from_peer != GlobalLobbyClient.lobby.host:
					for i in len(letter_pad.word):
						if letter_pad.word[i] == guess:
							letter_pad.guessed_word[i] = guess
				update_word_on_peers()
			"update_word":
				# Only host can update word
				if from_peer == GlobalLobbyClient.lobby.host:
					var update_word = data["word"]
					# Host doesnt update his word
					if GlobalLobbyClient.is_host():
						return
					letter_pad.update_word(update_word)

func update_word_on_peers():
	var result : LobbyResult = await GlobalLobbyClient.lobby_data({"command": "update_word", "word": letter_pad.guessed_word}).finished
	if result.has_error():
		logs.text = result.error
	if letter_pad.guessed_word == letter_pad.word:
		await get_tree().create_timer(0.5).timeout
		leave_lobby()

func leave_lobby():
	var result : LobbyResult = await GlobalLobbyClient.leave_lobby().finished
	if result.has_error():
		logs.text = result.error
	else:
		logs.text = "Left Succesfuly"

func _lobby_left():
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_packed(main_menu_scene)

func _on_set_word_pressed() -> void:
	var result : LobbyResult = await GlobalLobbyClient.lobby_data({"command": "count", "count": len(letter_pad.word) / 2}).finished
	if result.has_error():
		logs.text = result.error

func _append_log(command: String, message: String):
	logs.text = message

func _on_leave_pressed() -> void:
	leave_lobby()
