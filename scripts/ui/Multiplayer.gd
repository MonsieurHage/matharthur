# Multiplayer.gd
extends Node3D

@onready var vbox = $UI/Root/VBox/Scroll/Content
@onready var wallet_label = $UI/Root/VBox/TopBar/Wallet

func _ready():
	$UI/Root/VBox/TopBar/BackBtn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/MainMenu.tscn"))
	wallet_label.text = "🪙 " + str(GameState.state["wallet"])
	_render()

func _render():
	for c in vbox.get_children(): c.queue_free()
	if not GameState.state["unlockedMultiplayer"]:
		var lock = Label.new()
		lock.text = "🔒 Multijoueur verrouillé\n\nIl faut 500 🪙 dans le porte-monnaie pour débloquer le mode multijoueur.\nTu as actuellement " + str(GameState.state["wallet"]) + " 🪙."
		lock.horizontal_alignment = 1
		lock.autowrap_mode = 2
		vbox.add_child(lock)
		var btn = Button.new()
		btn.text = "Débloquer (500 🪙)"
		btn.disabled = GameState.state["wallet"] < 500
		btn.pressed.connect(_unlock)
		vbox.add_child(btn)
		return
	# unlocked
	var info = Label.new()
	info.text = "👥 Mode Multijoueur (démo locale)\nAffronte des bots ou invite des amis (bientôt en ligne)."
	info.horizontal_alignment = 1
	info.autowrap_mode = 2
	vbox.add_child(info)
	# bot players
	for i in range(3):
		var row = HBoxContainer.new()
		var av = Label.new(); av.text = ["🧙‍♂️","🧝‍♂️","🐉"][i]; av.add_theme_font_size_override("font_size", 32)
		var name = Label.new(); name.text = "Bot " + str(i+1)
		var score = Label.new(); score.text = str(randi()%50) + " pts"
		row.add_child(av); row.add_child(name); row.add_child(score)
		vbox.add_child(row)
	var start = Button.new()
	start.text = "🎮 Lancer une partie multijoueur"
	start.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/Game.tscn"))
	vbox.add_child(start)

func _unlock():
	if Wallet.unlock_multiplayer():
		_toast("Multijoueur débloqué !", "")
		_render()
	else:
		_toast("Pas assez de 🪙", "")

func _toast(msg, kind):
	print("[TOAST] ", msg)
