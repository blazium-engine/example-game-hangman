extends ColorRect

@export var lobby: BlaziumLobby

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lobby.connect_to_lobby()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
