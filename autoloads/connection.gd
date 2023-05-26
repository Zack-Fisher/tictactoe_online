extends HTTPRequest

# define routes/types of connections we can make to the server.
const SESSION_INIT = "session_init"
const SESSION_DEINIT = "session_deinit"
const MOVE = "move"
const POLL_PLAYER_STATE = "poll_player_state"
const POLL_GAME_STATUS = "poll_game_status"

const ERROR = "error"

const PROTOCOL = "http"
const HOST = "localhost"
const PORT = 8082

# we're always sending json requests.
const headers = ["Content-Type: application/json"]

# given to us by the server, we constantly pass it back and forth in our requests.
var id = null

func get_address(route = ""):
	return PROTOCOL + "://" + HOST + ":" + str(PORT) + "/" + route

func _ready():
	request_completed.connect(_request_completed)

var poll_count := 0.0


# run polling operations to update the local state through the autoload, to minimize what the direct scene frontend needs to do.
func _process(delta):
	poll_count += delta
	if poll_count > 1.0:
		poll()
		poll_count = 0.0

func _request_completed(result, response_code, headers, body):
	if response_code != 200:
		print("Error: " + str(result) + " " + str(response_code))
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	if json.has("type"):
		match json["type"]:
			SESSION_INIT:
				handle_session_init(json)
			SESSION_DEINIT:
				handle_session_deinit(json)
			MOVE:
				handle_move(json)
			POLL_PLAYER_STATE:
				handle_poll_player_state(json) 
			POLL_GAME_STATUS:
				handle_poll_game_status(json)
			# special return type, with a simple json message parameter.
			ERROR:
				print("Error: " + json["message"])

# send the session initializer.
func send_session_init(data):
	print("sending session init")
	var json = JSON.stringify(data)
	print(json)
	request(get_address("api/" + SESSION_INIT), headers, HTTPClient.METHOD_POST, json)

func send_session_deinit(data):
	# the connection singleton adds the id contexts to our requests for us.
	data["id"] = id
	var json = JSON.stringify(data)
	request(get_address("api/" + SESSION_DEINIT), headers, HTTPClient.METHOD_POST, json)

func send_move(data):
	data["id"] = id
	var json = JSON.stringify(data)
	request(get_address("api/" + MOVE), headers, HTTPClient.METHOD_POST, json)

func send_poll_player_state(data):
	data["id"] = id
	var json = JSON.stringify(data)
	request(get_address("api/" + POLL_PLAYER_STATE), headers, HTTPClient.METHOD_POST, json)

func send_poll_game_status(data):
	data["id"] = id
	var json = JSON.stringify(data)
	request(get_address("api/" + POLL_GAME_STATUS), headers, HTTPClient.METHOD_POST, json)

# the all-in-one polling function.
# all called at the same time. maybe spread them out, and have a different polling rate for each?
# we can skip polling the game_status when the game is not in progress.
func poll():
	if State.player == null:
		return
	send_poll_player_state({})
	if State.player.state == Player.PLAYING:
		send_poll_game_status({})


## take in the responses from the server.
## handlers will modify local state, which the scenes will poll from.
## we're basically using a double-polling model, we use the autoload server to poll the http server, and the scenes poll the autoload server.
func handle_session_init(json):
	print("session init")
	id = json["id"]
	var name = json["name"]
	# update the model
	# make a new player. the init method is only called once per session, so it doesn't matter.
	State.set_player(Player.new(name))
	print("session id: " + str(id))

func handle_session_deinit(json):
	State.set_player(null)
	print("session deinit")

func handle_move(json):
	pass

func handle_poll_player_state(json):
	# update the player state.
	State.player.state = json["state"]

func handle_poll_game_status(json):
	# update the game state.
	pass
