extends Node

# Game manager handles scoring, crash count, coin collection and win/lose logic.

var score = 0
var coins = 0
var wheelie_seconds = 0.0
var jumps = 0
var crashes = 0
var crash_limit = 3
var start_time = 0.0
var finished = false

onready var player = null

func _ready():
    start_time = OS.get_unix_time()
    # Try to find player automatically
    player = get_tree().get_root().find_node("Player", true, false)
    if player:
        player.connect("did_jump", Callable(self, "on_player_jump"))
        player.connect("did_land", Callable(self, "on_player_land"))
        player.connect("did_crash", Callable(self, "on_player_crash"))
        player.connect("did_flip", Callable(self, "on_player_flip"))

func on_player_jump(height):
    jumps += 1
    if height < 300:
        score += 150 # small jump
    else:
        score += 300 # big jump

func on_player_land(landing_velocity, perfect):
    if perfect:
        score += 100

func on_player_flip(direction):
    # direction 1 = backflip, -1 = frontflip
    score += 500

func on_player_crash():
    crashes += 1
    score = max(0, score - 250)
    if crashes >= crash_limit:
        game_over()

func collect_coin():
    coins += 1
    score += 50

func update_wheelie(delta):
    # Called from Main loop to add wheelie points
    if player and player.is_wheelie:
        score += 100 * delta
        wheelie_seconds += delta

func game_over():
    if finished:
        return
    finished = true
    print("Game Over - total score: %d" % score)
    # In a real project emit a signal or change to GameOver scene

func finish_race():
    if finished:
        return
    finished = true
    var total_time = OS.get_unix_time() - start_time
    print("Finished! Time: %d, Score: %d" % [total_time, score])
