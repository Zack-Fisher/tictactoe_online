extends Control

@onready var player_info: PanelContainer = %PlayerInfoContainer
@onready var general_info: PanelContainer = %GeneralInfoContainer
@onready var opponent_info: PanelContainer = %OpponentInfoContainer

@onready var player_move_selector: PanelContainer = %PlayerMoveSelector

var player_info_card_scene = preload("res://scenes/PlayerCard.tscn")

# we should have a player in the state by now.
func _ready():
	var my_card = player_info_card_scene.instantiate()
	my_card._player = State.player
	player_info.add_child(my_card)

# poll the poller autoloads for changes in state, wait for the playing state on the player.
func _process(delta):
	if State.game:
		# if we've made a move this turn
		if State.game.my_move:
			player_move_selector.visible = false
		else:
			player_move_selector.visible = true


func send_move_helper(move):
	State.game.my_move = move
	Connection.send_move({
		"move": move,
	})

func _on_rock_pressed():
	send_move_helper(Player.ROCK)

func _on_paper_pressed():
	send_move_helper(Player.PAPER)

func _on_scissors_pressed():
	send_move_helper(Player.SCISSORS)
