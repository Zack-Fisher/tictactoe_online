extends Resource
class_name Player

const MATCHING = "matching"
const PLAYING = "playing"
const END = "end"

const ROCK = 'rock'
const PAPER = 'paper'
const SCISSORS = 'scissors'

func _init(name):
    self.name = name

# stores the data, not the id.
var name = "Player"
# the default state anyway.
var state = MATCHING
