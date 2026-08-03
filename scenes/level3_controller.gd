extends Node2D

onready var coin_scene = load("res://scenes/Coin.tscn")
onready var obs_scene = load("res://scenes/Obstacle.tscn")

func _ready():
    var coins_parent = get_node("Coins")
    var obs_parent = get_node("Obstacles")

    # long gaps and more obstacles, a few coin clusters to reward risk
    for i in range(9):
        var c = coin_scene.instantiate()
        c.position = Vector2(300 + i * 260, 90 - (i % 4) * 45)
        coins_parent.add_child(c)

    for i in range(6):
        var o = obs_scene.instantiate()
        o.position = Vector2(420 + i * 420, 210 - (i % 3) * 40)
        obs_parent.add_child(o)
