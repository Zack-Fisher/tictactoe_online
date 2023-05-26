const express = require('express');

const { v4: uuidv4 } = require('uuid');

const app = express();
app.use(express.json());

const SESSION_INIT = "session_init"
const SESSION_DEINIT = "session_deinit"
const MOVE = "move"
// see if the player has been matched with another player.
const POLL_PLAYER_STATE = "poll_player_state"
// see if the game has processed, eg the other player has moved.
const POLL_GAME_STATUS = "poll_game_status"

const Moves = {
    ROCK: "rock",
    PAPER: "paper",
    SCISSORS: "scissors",
}

const State = {
    MATCHING: "matching",
    PLAYING: "playing",
    END: "end",
}

class Game {
    constructor(user_one_id, user_two_id) {
        this.one_id = user_one_id;
        this.two_id = user_two_id;

        this.one_wincount = 0;
        this.two_wincount = 0;

        // the moves that the players have made. once both are set, the game is processed.
        this.one_move = null;
        this.two_move = null;
    }
}

class User {
    constructor(name) {
        this.name = name;
        this.state = State.MATCHING;
    }
}

let user_map = new Map();
let games = [];

app.post('/api/' + SESSION_INIT, (req, res) => {
    // pass the user's name in 
    const { name } = req.body;

    console.log(name)

    // Generate a UUID
    const uuid = uuidv4();
    user_map.set(uuid, new User(name));

    // Create a JSON response object
    const response = {
        type: SESSION_INIT,
        id: uuid,
        // mirror the name, so that the godot handler can easily construct the local player model from it.
        name: name,
    };

    res.json(response);
});

app.post('/api/' + SESSION_DEINIT, (req, res) => {
    const { id } = req.body;

    user_map.delete(id);

    const response = {
        type: SESSION_DEINIT,
    };

    res.json(response);
});

app.post('/api/' + MOVE, (req, res) => {
    // pass either ROCK, PAPER, or SCISSORS in the move param.
    // also still pass the id
    const { id, move } = req.body;

    let game = games.find(game => game.one_id == id || game.two_id == id);

    if (game == undefined) {
        res.json({ type: "error", message: "user not in game" });
        return;
    }

    game.one_move = move;

    const response = {
        type: MOVE,
        // so that the local players know who sent the move.
        id: id,
    };

    res.json(response);
});

app.post('/api/' + POLL_GAME_STATUS, (req, res) => {
    const {id} = req.body;

    const response = {
        type: POLL_GAME_STATUS,
    }

    res.json(response);
});

// just have a general purpose route that returns the player's state.
app.post('/api/' + POLL_PLAYER_STATE, (req, res) => {
    const {id} = req.body;

    const user = user_map.get(id);
    if (user == undefined) {
        res.json({ type: "error", message: "user not found" });
        return;
    }

    const response = {
        type: POLL_PLAYER_STATE,
        state: user.state,
    };

    res.json(response);
});

const matchmaking_loop = () => {
    let matching_users = [];

    console.log(user_map)

    // special map iteration.
    for (const [id, user] of user_map) {
        if (user.state == State.MATCHING)
        {
            matching_users.push(id);
        }
    }

    console.log("matching users: " + matching_users)

    while (matching_users.length >= 2) {
        const user_one_id = matching_users.pop();
        const user_two_id = matching_users.pop();

        const game = new Game(user_one_id, user_two_id);
        games.push(game);

        user_map.get(user_one_id).state = State.PLAYING;
        user_map.get(user_two_id).state = State.PLAYING;

        console.log("matched " + user_one_id + " and " + user_two_id)
    }
}

// try to matchmake the users in the group every second.
setInterval(matchmaking_loop, 1000);

// Start the server
const port = 8082;
app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});
