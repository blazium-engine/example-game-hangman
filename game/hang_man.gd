extends PanelContainer

@export var head: ColorRect
@export var body: ColorRect
@export var leftArm: ColorRect
@export var rightArm: ColorRect
@export var leftLeg: ColorRect
@export var rightLeg: ColorRect
@export var set_word_button: Button
@export var letter_pad: LetterPad
@export var logs: Label
@export var inputButtons: Container
var body_parts: Array[ColorRect]

var main_menu_scene : PackedScene = load("res://main_menu.tscn")
var lobby_viewer : PackedScene = load("res://menus/lobby_viewer/lobby_viewer.tscn")


func _ready() -> void:
	# Host sets the word initially
	if !GlobalLobbyClient.is_host():
		set_buttons_enabled(false)
		set_word_button.visible = false
	body_parts = [head, body, leftArm, rightArm, leftLeg, rightLeg]
	if GlobalLobbyClient.is_host():
		letter_pad.word = GlobalLobbyClient.host_data.get("word", "")
	var word = GlobalLobbyClient.lobby.data.get("guessed", "")
	var health = GlobalLobbyClient.lobby.data.get("health", 6)
	# Start guessing if word is set
	_start_guessing(word)
	# Take damage if needed
	if GlobalLobbyClient.lobby.data.has("health"):
		while health != len(body_parts):
			take_damage()
	GlobalLobbyClient.lobby_notified.connect(_lobby_notified)
	GlobalLobbyClient.lobby_left.connect(_lobby_left)
	GlobalLobbyClient.log_updated.connect(_append_log)
	GlobalLobbyClient.received_lobby_data.connect(_received_lobby_data)
	GlobalLobbyClient.disconnected_from_lobby.connect(_disconnected_from_lobby)
	GlobalLobbyClient.lobby_tagged.connect(_lobby_tagged)


func set_buttons_enabled(enabled: bool):
	for node: Button in inputButtons.get_children():
		node.disabled = !enabled


func _received_lobby_data(data: Dictionary, is_private: bool):
	if !is_private:
		_start_guessing(data.get("guessed", ""))
		# Take damage if needed
		if data.has("health"):
			while data.get("health", 6) != len(body_parts):
				take_damage()
		# Update the words highlighted
		for letter in data.get("pressed", {}):
			var node : Button = inputButtons.get_node("Button" + letter)
			node.flat = true
			node.text = ""
	
func _start_guessing(word):
	if word == "":
		return
	# Disable host input until peers guess the word
	if GlobalLobbyClient.is_host():
		set_buttons_enabled(false)
		set_word_button.disabled = true
		letter_pad.update_word(word)
		return
	set_buttons_enabled(true)
	letter_pad.update_word(word)


func _lobby_notified(data: Dictionary, from_peer: LobbyPeer):
		match data["command"]:
			"guess":
				var guess = data["letter"]
				var letters :Dictionary= GlobalLobbyClient.lobby.data.get("pressed", {})
				if letters.get(guess, 0) == 1:
					return
				letters[guess] = 1
				var result : LobbyResult = await GlobalLobbyClient.add_lobby_data({"pressed": letters}).finished
				if result.has_error():
					logs.text = result.error
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
		end_game()


func update_send_damage():
	update_host_data(1)

func end_game():
	# Delete private data
	var result: LobbyResult = await GlobalLobbyClient.del_lobby_data(GlobalLobbyClient.host_data.keys(), true).finished
	if result.has_error():
		logs.text = result.error
	# Delete public data
	result = await GlobalLobbyClient.del_lobby_data(GlobalLobbyClient.lobby.data.keys()).finished
	if result.has_error():
		logs.text = result.error
	# Stop the game
	result = await GlobalLobbyClient.add_lobby_tags({"game_state": "stopped"}).finished
	if result.has_error():
		logs.text = result.error

func take_damage():
	var body_part :ColorRect= body_parts.pop_back()
	if body_part == null:
		return
	body_part.visible = false
	if body_parts.is_empty():
		if is_inside_tree():
			await get_tree().create_timer(0.5).timeout
		end_game()


func _lobby_left(_kicked: bool):
	if is_inside_tree():
		get_tree().change_scene_to_packed(main_menu_scene)


func update_host_data(damage:= 0):
	# Set on lobby data the word and the guessed word so far
	var result : LobbyResult = await GlobalLobbyClient.add_lobby_data({"word": letter_pad.word}, true).finished
	if result.has_error():
		logs.text = result.error
	result = await GlobalLobbyClient.add_lobby_data({"guessed": letter_pad.guessed_word, "health": len(body_parts) - damage}).finished
	if result.has_error():
		logs.text = result.error


func _on_set_word_pressed() -> void:
	update_host_data()


func _append_log(command: String, message: String):
	logs.text = command + " " + message

func _lobby_tagged(tags: Dictionary):
	if tags.get("game_state", "stopped") == "stopped":
		if is_inside_tree():
			get_tree().change_scene_to_packed(lobby_viewer)
		

func leave_lobby():
	var result : LobbyResult = await GlobalLobbyClient.leave_lobby().finished
	if result.has_error():
		logs.text = result.error
	else:
		logs.text = "Left Succesfully"
	if is_inside_tree():
		get_tree().change_scene_to_packed(main_menu_scene)

func _on_leave_pressed() -> void:
	leave_lobby()


func _disconnected_from_lobby(_reason: String):
	if is_inside_tree():
		get_tree().change_scene_to_packed(main_menu_scene)
