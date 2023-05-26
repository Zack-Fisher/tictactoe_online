extends Control

@onready
var _name_edit = %NameEdit

const game_scene_path = "res://scenes/Game.tscn"

func _physics_process(delta):
	if Connection.id != null:
		get_tree().get_root().add_child(preload(game_scene_path).instantiate())
		queue_free()
		return

func _on_connect_button_pressed():
	var init_request = {
		"name": _name_edit.text,
	}
	Connection.send_session_init(init_request)
