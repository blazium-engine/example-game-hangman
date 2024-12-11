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
	# Host sets the word initially
	if !GlobalLobbyClient.is_host():
		set_buttons_enabled(false)
		set_word_button.visible = false
	body_parts = [head, body, leftArm, rightArm, leftLeg, rightLeg]
	if GlobalLobbyClient.is_host():
		letter_pad.word = GlobalLobbyClient.get_host_data().get("word", "")
		letter_pad.guessed_word = GlobalLobbyClient.get_host_data().get("guessed", "")
	var word = GlobalLobbyClient.lobby.data.get("guessed", "")
	var health = GlobalLobbyClient.lobby.data.get("health", 6)
	# Start guessing if word is set
	_start_guessing(word)
	# Take damage if needed
	while health != len(body_parts):
		take_damage()
	GlobalLobbyClient.lobby_notified.connect(_lobby_nofitied)
	GlobalLobbyClient.lobby_left.connect(_lobby_left)
	GlobalLobbyClient.log_updated.connect(_append_log)
	GlobalLobbyClient.received_lobby_data.connect(_received_lobby_data)
	GlobalLobbyClient.disconnected_from_lobby.connect(_disconnected_from_lobby)

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

func _received_lobby_data(data: Dictionary, is_private: bool):
	if !is_private:
		_start_guessing(data.get("guessed", ""))
		# Take damage if needed
		while data.get("health", 6) != len(body_parts):
			take_damage()
	
func _start_guessing(word):
	print(word)
	if word == "":
		return
	# Disable host input until peers guess the word
	if GlobalLobbyClient.is_host():
		set_buttons_enabled(false)
		set_word_button.disabled = true
		return
	set_buttons_enabled(true)
	letter_pad.update_word(word)

func _lobby_nofitied(data: Dictionary, from_peer: LobbyPeer):
		match data["command"]:
			"guess":
				var guess = data["letter"]
				# Only peers can guess, this only calls to the host
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

func update_word_on_peers():
	# Update guessed word for host
	update_host_data()
	if letter_pad.guessed_word == letter_pad.word:
		if is_inside_tree():
			await get_tree().create_timer(0.5).timeout
		leave_lobby()

func update_send_damage():
	update_host_data(1)

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
		get_tree().change_scene_to_packed(main_menu_scene)

func update_host_data(damage:= 0):
	# Set on lobby data the word and the guessed word so far
	var result : LobbyResult = await GlobalLobbyClient.set_lobby_data({"word": letter_pad.word}, true).finished
	if result.has_error():
		logs.text = result.error
	result = await GlobalLobbyClient.set_lobby_data({"guessed": letter_pad.guessed_word, "health": len(body_parts) - damage}).finished
	if result.has_error():
		logs.text = result.error

@warning_ignore("integer_division")
func _on_set_word_pressed() -> void:
	update_host_data()

func _append_log(command: String, message: String):
	logs.text = command + " " + message

func _on_leave_pressed() -> void:
	leave_lobby()

func _disconnected_from_lobby(_reason: String):
	if is_inside_tree():
		get_tree().change_scene_to_packed(main_menu_scene)
