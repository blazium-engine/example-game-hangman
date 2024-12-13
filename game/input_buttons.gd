@tool
extends Container

signal letter_pressed(index: int)
signal delete_pressed()

@export var button_size := Vector2(32, 32):
	set(value):
		button_size = value
		update_minimum_size()
		queue_sort()

@export var h_margin := 8:
	set(value):
		h_margin = value
		update_minimum_size()
		queue_sort()

@export var v_margin := 8:
	set(value):
		v_margin = value
		update_minimum_size()
		queue_sort()


func _get_minimum_size() -> Vector2:
	return Vector2(button_size.x * 7, button_size.y * 4) + Vector2(h_margin * 6, v_margin * 3)

@warning_ignore("integer_division")
func _sort_children() -> void:
	var _child_count = get_child_count() - 1
	for i in _child_count:
		var rect = Rect2((button_size + Vector2(h_margin, v_margin)) * Vector2(i % 7, floor(i / 7)), button_size)
		fit_child_in_rect(get_child(i), rect)
	fit_child_in_rect(get_child(_child_count), Rect2((button_size + Vector2(h_margin, v_margin)) * Vector2(_child_count % 7, floor(_child_count / 7)), Vector2(button_size.x * 2 + h_margin, button_size.y)))


func _init() -> void:
	var abc: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	for i in abc.length():
		var letter_button: Button = Button.new()
		letter_button.name = "Button"+ abc[i]
		letter_button.text = abc[i]
		letter_button.pressed.connect(_on_letter_pressed.bind(i))
		add_child(letter_button)
	var button: Button = Button.new()
	button.text = "Del"
	button.set_deferred("size_flags_horizontal", Control.SIZE_EXPAND_FILL)
	if GlobalLobbyClient.is_host():
		button.pressed.connect(func(): delete_pressed.emit())
	add_child(button)
	sort_children.connect(_sort_children)


func _on_letter_pressed(index: int) ->void:
	letter_pressed.emit(index)
