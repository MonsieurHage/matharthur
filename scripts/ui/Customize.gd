# Customize.gd
extends Node3D

@onready var avatar_big = $UI/Root/VBox/Scroll/Content/AvatarBig
@onready var tabs = $UI/Root/VBox/Scroll/Content/Tabs
@onready var grid = $UI/Root/VBox/Scroll/Content/Grid
@onready var wallet_label = $UI/Root/VBox/TopBar/Wallet

var current_cat: String = "avatars"

func _ready():
	$UI/Root/VBox/TopBar/BackBtn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/MainMenu.tscn"))
	_build_tabs()
	_build_grid()
	_update_ui()

func _update_ui():
	wallet_label.text = "🪙 " + str(GameState.state["wallet"])
	var eq = GameState.state["equipped"]
	var av_id = eq["avatar"]
	avatar_big.text = _icon("avatars", av_id)
	if eq["hat"] != "": avatar_big.text += " " + _icon("hats", eq["hat"])
	if eq["pet"] != "": avatar_big.text += "\n" + _icon("pets", eq["pet"])

func _icon(cat, id):
	for it in ShopDB.ITEMS[cat]:
		if it["id"]==id: return it["icon"]
	return ""

func _build_tabs():
	for c in tabs.get_children(): c.queue_free()
	for cat in ShopDB.CATEGORIES:
		var b = Button.new()
		b.text = cat["icon"] + " " + cat["label"]
		b.pressed.connect(func(): _select_cat(cat["key"]))
		tabs.add_child(b)

func _select_cat(key):
	current_cat = key
	_build_grid()

func _build_grid():
	for c in grid.get_children(): c.queue_free()
	for it in ShopDB.ITEMS[current_cat]:
		var panel = VBoxContainer.new()
		var icon = Label.new(); icon.text = it["icon"]; icon.horizontal_alignment = 1; icon.add_theme_font_size_override("font_size", 32)
		var name = Label.new(); name.text = it["name"]; name.horizontal_alignment = 1
		var price = Label.new()
		var owned = ShopDB.is_owned(current_cat, it["id"])
		var equipped = _is_equipped(current_cat, it["id"])
		if owned:
			price.text = "Possédé" if not equipped else "Équipé"
		else:
			price.text = str(it["price"]) + " 🪙"
		price.horizontal_alignment = 1
		var btn = Button.new()
		btn.text = "Équiper" if owned else "Acheter"
		btn.pressed.connect(func(): _on_item(it))
		panel.add_child(icon); panel.add_child(name); panel.add_child(price); panel.add_child(btn)
		grid.add_child(panel)

func _is_equipped(cat, id):
	var eq = GameState.state["equipped"]
	match cat:
		"avatars": return eq["avatar"]==id
		"hats": return eq["hat"]==id
		"pets": return eq["pet"]==id
		"backgrounds": return eq["bg"]==id
		"effects": return eq["effect"]==id
	return false

func _on_item(it):
	var id = it["id"]; var cat = current_cat
	if ShopDB.is_owned(cat, id):
		# equip
		match cat:
			"avatars": GameState.state["equipped"]["avatar"]=id; GameState.state["player"]["avatar"]=id
			"hats": GameState.state["equipped"]["hat"]=id
			"pets": GameState.state["equipped"]["pet"]=id
			"backgrounds": GameState.state["equipped"]["bg"]=id
			"effects": GameState.state["equipped"]["effect"]=id
		GameState.save()
		_update_ui(); _build_grid()
	else:
		if ShopDB.buy(cat, id):
			_toast("Acheté ! " + it["icon"], "")
			_update_ui(); _build_grid()
		else:
			_toast("Pas assez de 🪙", "")

func _toast(msg, kind):
	print("[TOAST] ", msg)
