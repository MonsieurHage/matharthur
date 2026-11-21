# MainMenu.gd
extends Node3D

@onready var wallet_label = $UI/Root/VBox/TopBar/Wallet
@onready var streak_label = $UI/Root/VBox/TopBar/Streak
@onready var avatar_label = $UI/Root/VBox/Scroll/Content/Avatar
@onready var level_label = $UI/Root/VBox/Scroll/Content/Level
@onready var xp_bar = $UI/Root/VBox/Scroll/Content/XPBar
@onready var domains_grid = $UI/Root/VBox/Scroll/Content/Domains

var domain_buttons: Array = []

func _ready():
	_update_ui()
	_build_domains()
	var btns = $UI/Root/VBox/Scroll/Content/Buttons
	btns.get_node("PlayBtn").pressed.connect(_on_play)
	btns.get_node("CustomizeBtn").pressed.connect(_on_customize)
	btns.get_node("MultiBtn").pressed.connect(_on_multi)
	btns.get_node("LeaderBtn").pressed.connect(_on_leader)
	# animation rotation château
	var tween = create_tween().set_loops()
	tween.tween_property($Castle, "rotation:y", TAU, 8.0)

func _update_ui():
	wallet_label.text = "🪙 " + str(GameState.state["wallet"])
	streak_label.text = "🔥 " + str(GameState.state["stats"]["streak"])
	var p = GameState.state["player"]
	avatar_label.text = _avatar_icon(p["avatar"])
	level_label.text = "Niveau " + str(p["level"])
	var needed = p["level"] * 100
	xp_bar.max_value = needed
	xp_bar.value = p["xp"]

func _avatar_icon(id: String) -> String:
	for cat in ["avatars"]:
		for it in ShopDB.ITEMS[cat]:
			if it["id"] == id: return it["icon"]
	return "🧙‍♂️"

func _build_domains():
	for c in domains_grid.get_children():
		c.queue_free()
	for d in Adaptive.DOMAINS:
		var b = Button.new()
		var prog = GameState.get_domain_progress(d)
		var mastery = int(prog["mastery"]*100)
		b.text = d + "\n" + str(mastery) + "%"
		b.custom_minimum_size = Vector2(260, 60)
		b.pressed.connect(func(): _start_domain(d))
		domains_grid.add_child(b)

func _start_domain(domain: String):
	GameState.state["currentDomain"] = domain
	get_tree().change_scene_to_file("res://scenes/Mission.tscn")

func _on_play():
	var d = Adaptive.weakest_domain()
	_start_domain(d)

func _on_customize():
	get_tree().change_scene_to_file("res://scenes/Customize.tscn")

func _on_multi():
	get_tree().change_scene_to_file("res://scenes/Multiplayer.tscn")

func _on_leader():
	var lb = GameState.state["leaderboard"]
	var txt = "🏆 Classement\n\n"
	if lb.is_empty():
		txt += "Aucun score pour le moment."
	else:
		for i in range(lb.size()):
			txt += str(i+1) + ". " + lb[i]["name"] + " - " + str(lb[i]["score"]) + " pts\n"
	_toast_popup(txt)

func _toast_popup(msg: String):
	var dialog = AcceptDialog.new()
	dialog.dialog_text = msg
	add_child(dialog)
	dialog.popup_centered()
