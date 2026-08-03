extends Node2D

onready var coin_scene = load("res://scenes/Coin.tscn")
onready var obs_scene = load("res://scenes/Obstacle.tscn")

func _ready():
    var coins_parent = get_node("Coins")
    var obs_parent = get_node("Obstacles")

    # denser coins and some higher placements
    for i in range(7):
        var c = coin_scene.instantiate()
        c.position = Vector2(220 + i * 200, 100 - (i % 3) * 50)
        coins_parent.add_child(c)

    for i in range(5):
        var o = obs_scene.instantiate()
        o.position = Vector2(360 + i * 380, 220 - (i % 2) * 30)
        obs_parent.add_child(o)
