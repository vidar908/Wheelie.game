extends CanvasLayer

# Simple UI updater

onready var game_manager = get_tree().get_root().find_node("GameManager", true, false)
onready var hud = $"/root/Main/UI/HUD" if has_node("/root/Main/UI/HUD") else null

func _process(delta):
    var gm = get_node_or_null("/root/Main")
    # Try to find the game manager node
    var manager = get_tree().get_root().find_node("GameManager", true, false)
    if manager and hud:
        hud.text = "Score: %d\nCoins: %d\nCrashes: %d/%d" % [manager.score, manager.coins, manager.crashes, manager.crash_limit]
