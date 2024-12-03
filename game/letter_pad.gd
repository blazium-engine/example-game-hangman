class_name LetterPad
extends Node

var word := ""
var guessed_word := ""
@export var word_label: Label
@export var logs: Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_length(length: int):
	word_label.text = ""
	for i in length:
		word_label.text += "_ "

func update_word(p_word: String):
	word = p_word
	word_label.text = word

func letterPressed(buttonId: int):
	var letter := char(buttonId + 65)
	if GlobalLobbyClient.is_host():
		# Construct the word
		word += letter + " "
		guessed_word += "_ "
		word_label.text = word
	else:
		# Send the letter to the host
		var result :LobbyResult = await GlobalLobbyClient.send_lobby_data({"command": "guess", "letter": letter}).finished
		if result.has_error():
			logs.text = result.error
