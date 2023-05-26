extends Node
# we store the responses of our polling in a LOCAL model of the game's state.
# we render the local model to the frontend.

# the playerdata 
var player = null
# the game that they might be in
var game = null

func set_player(player):
    print("setting player")
    print(player)
    self.player = player

func set_game(game):
    print("setting game")
    print(game)
    self.game = game
