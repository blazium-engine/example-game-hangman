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
var body_parts : Array[ColorRect]

var main_menu_scene : PackedScene = load("res://main_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_parts = [head, body, leftArm, rightArm, leftLeg, rightLeg]
	GlobalLobbyClient.lobby_notified.connect(_lobby_nofitied)
	GlobalLobbyClient.lobby_left.connect(_lobby_left)
	GlobalLobbyClient.log_updated.connect(_append_log)
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

func _lobby_nofitied(data: Dictionary, from_peer: LobbyPeer):
		match data["command"]:
			"count":
				# Only host can set word length
				if from_peer.id == GlobalLobbyClient.lobby.host:
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
				var guessed = false
				if from_peer.id != GlobalLobbyClient.lobby.host:
					for i in len(letter_pad.word):
						if letter_pad.word[i] == guess:
							letter_pad.guessed_word[i] = guess
							guessed = true
				if guessed:
					update_word_on_peers()
				else:
					update_send_damage()
			"update_word":
				# Only host can update word
				if from_peer.id == GlobalLobbyClient.lobby.host:
					var update_word = data["word"]
					# Host doesnt update his word
					if GlobalLobbyClient.is_host():
						return
					letter_pad.update_word(update_word)
			"take_damage":
				# Only host can damage players
				if from_peer.id == GlobalLobbyClient.lobby.host:
					take_damage()

func update_word_on_peers():
	var result : LobbyResult = await GlobalLobbyClient.notify_lobby({"command": "update_word", "word": letter_pad.guessed_word}).finished
	if result.has_error():
		logs.text = result.error
	if letter_pad.guessed_word == letter_pad.word:
		if is_inside_tree():
			await get_tree().create_timer(0.5).timeout
		leave_lobby()

func update_send_damage():
	var result : LobbyResult = await GlobalLobbyClient.notify_lobby({"command": "take_damage"}).finished
	if result.has_error():
		logs.text = result.error

func take_damage():
	var body_part :ColorRect= body_parts.pop_back()
	body_part.visible = false
	if body_parts.is_empty():
		if is_inside_tree():
			await get_tree().create_timer(0.5).timeout
		leave_lobby()

func leave_lobby():
	var result : LobbyResult = await GlobalLobbyClient.leave_lobby().finished
	if result.has_error():
		logs.text = result.error
	else:
		logs.text = "Left Succesfuly"

func _lobby_left(_kicked: bool):
	if is_inside_tree():
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_packed(main_menu_scene)

@warning_ignore("integer_division")
func _on_set_word_pressed() -> void:
	var result : LobbyResult = await GlobalLobbyClient.notify_lobby({"command": "count", "count": len(letter_pad.word) / 2}).finished
	if result.has_error():
		logs.text = result.error

func _append_log(command: String, message: String):
	logs.text = command + " " + message

func _on_leave_pressed() -> void:
	leave_lobby()
