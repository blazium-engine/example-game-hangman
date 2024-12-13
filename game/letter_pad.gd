class_name LetterPad
extends Node

var word: String = ""
var guessed_word: String = ""
@export var word_label: Label
@export var logs: Label


func update_word(p_word: String):
	word_label.text = p_word


func letterPressed(buttonId: int):
	if word_label.text.length() >= 10:
		return
	var letter := char(buttonId + 65)
	if GlobalLobbyClient.is_host():
		# Construct the word
		word += letter
		guessed_word += "_"
		word_label.text = word
	else:
		# Send the letter to the host
		var result :LobbyResult = await GlobalLobbyClient.notify_lobby({"command": "guess", "letter": letter}).finished
		if result.has_error():
			logs.text = result.error


func _on_delete_pressed() -> void:
	for peer in GlobalLobbyClient.peers:
		print(peer.peer_name)
	if GlobalLobbyClient.is_host() && word_label.text.length() > 0:
		word = word.left(-1)
		guessed_word = guessed_word.left(-1)
		word_label.text = word_label.text.left(-1)
