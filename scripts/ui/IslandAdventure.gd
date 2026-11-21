extends Node3D

const Art := preload("res://scripts/ui/IslandArt.gd")
const UI := preload("res://scripts/ui/ArtUI.gd")
const MENU := "res://scenes/MainMenu.tscn"
const TOTAL := 10
const WALK_SPEED := 7.0
const RUN_SPEED := 11.0
const JUMP_SPEED := 8.1
const GRAVITY := 24.0

@export var open_on_menu := false

var art: Node3D
var shared_sky: Sky
var camera: Camera3D
var layer: CanvasLayer
var screen: Control
var play_target: Label
var wardrobe_scroll: ScrollContainer
var quiz_scroll: ScrollContainer
var quiz_card: PanelContainer
var quiz: VBoxContainer
var movement := Vector2.ZERO
var buttons: Array[Button] = []
var hint: Label
var info: Label
var next: Button
var domain: String
var question: Dictionary
var seen: Array = []
var index := 0
var score := 0
var earned := 0
var attempts := 0
var last_slot := -1
var mode := ""
var clock := 0.0
var correct_slot := 0
var wardrobe_back := false
var orbit_yaw := 0.19
var orbit_pitch := 0.60
var orbit_distance := 13.5
var rotating_mouse := false
var rotate_touch := -1
var jump_requested := false
var touch_run := false
var touch_buttons: Array[Dictionary] = []
var move_touches: Dictionary = {}
var run_button: Button

var started_once := false
var tondeuse_min_area := 300.0
var tondeuse_area := 0.0

func _ready() -> void:
	_set_world(0)
	camera = Camera3D.new()
	camera.fov = 54
	add_child(camera)
	camera.make_current()
	layer = CanvasLayer.new()
	add_child(layer)
	get_viewport().size_changed.connect(_resize)
	if open_on_menu:
		_menu()
	else:
		_start(GameState.state.get("currentDomain", Adaptive.weakest_domain()))

func _set_world(theme_index: int, preview: bool = false) -> void:
	if is_instance_valid(art):
		remove_child(art)
		art.queue_free()
	art = Art.new()
	art.biome = theme_index
	art.preview_only = preview
	art.shared_sky = shared_sky
	add_child(art)
	shared_sky = art.shared_sky

func _new_screen(name_value: String) -> void:
	mode = name_value
	movement = Vector2.ZERO
	jump_requested = false
	touch_buttons.clear()
	move_touches.clear()
	_release_camera()
	camera.h_offset = 0
	camera.v_offset = 0
	Speech.stop()
	if is_instance_valid(screen):
		layer.remove_child(screen)
		screen.queue_free()
	screen = Control.new()
	layer.add_child(screen)
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _scroll() -> VBoxContainer:
	var fill := ColorRect.new()
	fill.color = Color("#ecf6fb")
	screen.add_child(fill)
	fill.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	quiz_scroll = ScrollContainer.new()
	quiz_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	screen.add_child(quiz_scroll)
	quiz_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_KEEP_SIZE, 12)
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	quiz_scroll.add_child(center)
	quiz_card = UI.card()
	center.add_child(quiz_card)
	var content := UI.column()
	quiz_card.add_child(content)
	_resize()
	return content

func _button(parent: Container, title: String, action: Callable, primary: bool = false) -> Button:
	var button := UI.button(title, primary)
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func _flow() -> HFlowContainer:
	var container := HFlowContainer.new()
	container.add_theme_constant_override("h_separation", 8)
	container.add_theme_constant_override("v_separation", 8)
	return container

func _menu() -> void:
	if art.preview_only:
		_set_world(0)
	_new_screen("menu")
	var panel := UI.card(UI.PAPER, 22)
	screen.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
	var content := UI.column(10)
	panel.add_child(content)
	content.add_child(UI.label("MATHARTHUR   /   AVENTURE CM2", 14, UI.BLUE))
	content.add_child(UI.label("L’île aux drapeaux", 35))
	content.add_child(UI.label("Explore l’île, trouve un drapeau, puis résous une énigme à ton rythme.", 18, UI.MUTED))
	_button(content, "Commencer l’aventure", func(): _start(Adaptive.weakest_domain()), true)
	var choices := OptionButton.new()
	UI.style_button(choices)
	choices.add_item("Choisir un thème de maths")
	for section in Adaptive.DOMAINS:
		choices.add_item(section)
	choices.item_selected.connect(func(slot: int):
		if slot > 0:
			_start(Adaptive.DOMAINS[slot - 1]))
	content.add_child(choices)
	var links := _flow()
	content.add_child(links)
	_button(links, "Atelier d’Arthur", _wardrobe)
	_button(links, "Multijoueur", func(): get_tree().change_scene_to_file("res://scenes/Multiplayer.tscn"))
	_button(links, "Mes scores", _scores)
	content.add_child(UI.label("%d %s dans ton porte-monnaie" % [Wallet.get_balance(), ShopDB.CURRENCY], 15, UI.MUTED))
	quiz_card = panel
	art.avatar.rotation.y = 2.5
	_resize()

func _start(selected_domain: String) -> void:
	domain = selected_domain
	GameState.state["currentDomain"] = domain
	var biome := maxi(0, Adaptive.DOMAINS.find(domain))
	if biome != art.biome or art.preview_only:
		_set_world(biome)
	_show_island()

func _show_island() -> void:
	_new_screen("island")
	if is_instance_valid(art.shipwalk):
		art.shipwalk.position = Vector3(38, 2.2, -10)
	art.flag.position = art.target_at(index)
	art.flag.show()
	var panel := UI.card(UI.PAPER, 12)
	panel.custom_minimum_size.x = 254
	screen.add_child(panel)
	panel.position = Vector2(12, 12)
	var group := UI.column(4)
	panel.add_child(group)
	group.add_child(UI.label("MISSION %02d / %02d" % [index + 1, TOTAL], 13, UI.BLUE))
	group.add_child(UI.label(Art.NAMES[art.biome], 21))
	group.add_child(UI.label("Trouve le drapeau corail", 15, UI.MUTED))
	play_target = UI.label("", 15, UI.MUTED)
	group.add_child(play_target)
	_button(group, "Retour au menu", _back)
	quiz_card = panel
	var pad := UI.card(UI.PAPER, 8)
	screen.add_child(pad)
	pad.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	pad.offset_left = 12
	pad.offset_right = 228
	pad.offset_top = -130
	pad.offset_bottom = -12
	var rows := UI.column(4)
	pad.add_child(rows)
	var up := UI.row(4)
	up.alignment = BoxContainer.ALIGNMENT_CENTER
	rows.add_child(up)
	_direction(up, "Haut", Vector2.UP)
	var across := UI.row(4)
	across.alignment = BoxContainer.ALIGNMENT_CENTER
	rows.add_child(across)
	_direction(across, "Gauche", Vector2.LEFT)
	_direction(across, "Bas", Vector2.DOWN)
	_direction(across, "Droite", Vector2.RIGHT)
	pad.visible = DisplayServer.is_touchscreen_available() or get_viewport().get_visible_rect().size.x < 700
	if pad.visible:
		group.add_child(UI.label("Glisse sur le décor pour tourner la caméra.", 14, UI.MUTED))
		var actions := UI.card(UI.PAPER, 7)
		screen.add_child(actions)
		actions.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
		actions.offset_left = -141
		actions.offset_top = -128
		actions.offset_right = -12
		actions.offset_bottom = -12
		var stack := UI.column(4)
		actions.add_child(stack)
		var jump_button := _button(stack, "Sauter", _request_jump, true)
		jump_button.focus_mode = Control.FOCUS_NONE
		run_button = _button(stack, "Courir", _toggle_run)
		run_button.focus_mode = Control.FOCUS_NONE
		run_button.text = "Marcher" if touch_run else "Courir"
		touch_buttons.append({"button": jump_button, "action": "jump"})
		touch_buttons.append({"button": run_button, "action": "run"})
	else:
		group.add_child(UI.label("ZQSD / WASD ou flèches • Maj : courir\nEspace : sauter • Clic droit + souris : caméra\nMolette : zoom", 14, UI.MUTED))
	var body: CharacterBody3D = art.avatar
	body.velocity = Vector3.ZERO
	_update_camera()
	_enter_tondeuse()
	_resize()

var tondeuse_zone := Vector3.ZERO
var tondeuse_done := false
var tondeuse_overlay: PanelContainer
var tondeuse_progressbar: ProgressBar
var tondeuse_hint_label: Label

func _enter_tondeuse() -> void:
	if biome != 0 or tondeuse_done:
		return
	tondeuse_zone = target_at(2) + Vector3(24, 0, 6)
	tondeuse_area = 0.0
	tondeuse_overlay = UI.card(UI.PAPER, 8)
	screen.add_child(tondeuse_overlay)
	tondeuse_overlay.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	tondeuse_overlay.offset_left = 12
	tondeuse_overlay.offset_right = 312
	tondeuse_overlay.offset_top = -150
	tondeuse_overlay.offset_bottom = -12
	var col := UI.column(6)
	tondeuse_overlay.add_child(col)
	tondeuse_hint_label = UI.label("Tu as tonner le massif, roule au massif et \nplante la tondeuse", 14, UI.INK)
	col.add_child(tondeuse_hint_label)
	var bar := UI.xp_track(0, 60)
	bar.custom_minimum_size.x = 260
	col.add_child(bar)
	tondeuse_progressbar = bar
	_update_tondeuse(0.0)

func _update_tondeuse(delta: float) -> void:
	var body: CharacterBody3D = art.avatar
	var zone_dist := body.position.distance_to(tondeuse_zone)
	var speed := clampf(9.0 - zone_dist, 0.0, 3.0) * maxf(0.35, 1.0 - tondeuse_area / 60.0)
	if speed > 0.4:
		tondeuse_area = minf(tondeuse_min_area, tondeuse_area + speed * 3.0 * delta)
	if zone_dist < 8:
		tondeuse_area = minf(tondeuse_min_area, tondeuse_area + 0.6 * delta)
	var recalled := tondeuse_area >= tondeuse_min_area
	if tondeuse_progressbar != null:
		tondeuse_progressbar.value = tondeuse_area
	tondeuse_hint_label.text = "Plante la tondeuse quand tu es au massif" if recalled else "Roule au massif : %dm" % int(ceili(tondeuse_zone.distance_to(body.position) - 8.0))
	if is_instance_valid(tondeuse_overlay):
		tondeuse_overlay.visible = not recalled
	if recalled:
		_tondeuse_done()

func _tondeuse_cut() -> void:
	var body: CharacterBody3D = art.avatar
	if body.position.distance_to(tondeuse_zone) < 8 and not tondeuse_done:
		tondeuse_area = minf(tondeuse_min_area, tondeuse_area + 10)
		_toast("Planté la tondeuse !", "")

func _tondeuse_done() -> void:
	tondeuse_done = true
	Wallet.add(30)
	GameState.add_xp(30)
	GameState.record_answer("Nombres et calculs", true)
	_toast("Bon travail ! Tondage effectué", "")
	# Continue to flag hunt for biome 0
	_check_tondeuse_campaign()

func _check_tondeuse_campaign() -> void:
	if tondeuse_done:
		tondeuse_overlay.hide() if is_instance_valid(tondeuse_overlay) else null
		started_once = true

func _toast(msg: String, kind: String = ""):
	print("[TOAST] ", msg)

func _direction(parent: Container, title: String, vector: Vector2) -> void:
	var button := UI.button(title)
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size.x = 58
	parent.add_child(button)
	touch_buttons.append({"button": button, "action": vector})
	button.button_down.connect(func(): movement = vector)
	button.button_up.connect(func():
		if movement == vector:
			movement = Vector2.ZERO)

func _camera_offset() -> Vector3:
	return Vector3(sin(orbit_yaw) * cos(orbit_pitch), sin(orbit_pitch),
		cos(orbit_yaw) * cos(orbit_pitch)) * orbit_distance

func _update_camera() -> void:
	var pivot: Vector3 = art.avatar.position + Vector3.UP * 1.28
	var offset := _camera_offset()
	var query := PhysicsRayQueryParameters3D.create(pivot, pivot + offset, 1)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		var hit_position: Vector3 = hit["position"]
		offset = offset.normalized() * maxf(0.45, pivot.distance_to(hit_position) - 0.4)
	camera.position = pivot + offset
	camera.look_at(pivot)

func _orbit(relative: Vector2) -> void:
	orbit_yaw = wrapf(orbit_yaw - relative.x * 0.006, -PI, PI)
	orbit_pitch = clampf(orbit_pitch + relative.y * 0.0055, 0.06, 1.40)

func _request_jump() -> void:
	jump_requested = true

func _toggle_run() -> void:
	touch_run = not touch_run
	if is_instance_valid(run_button):
		run_button.text = "Marcher" if touch_run else "Courir"

func _release_camera() -> void:
	if rotating_mouse:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	rotating_mouse = false
	rotate_touch = -1

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_release_camera()
		movement = Vector2.ZERO
		move_touches.clear()

func _input(event: InputEvent) -> void:
	if mode != "island":
		return
	if event.is_action_pressed("jump") and not event.is_echo():
		_request_jump()
		get_viewport().set_input_as_handled()
		return
	# Godot also generates mouse events for the first finger. Gameplay buttons
	# handle the original touches themselves so two fingers can act at once.
	if event is InputEventMouseButton and event.device == InputEvent.DEVICE_ID_EMULATION:
		for item in touch_buttons:
			var button: Button = item["button"]
			if button.is_visible_in_tree() and button.get_global_rect().has_point(event.position):
				get_viewport().set_input_as_handled()
				return
	if event is InputEventScreenTouch:
		if not event.pressed:
			if event.index == rotate_touch:
				rotate_touch = -1
			if move_touches.erase(event.index):
				get_viewport().set_input_as_handled()
			return
		for item in touch_buttons:
			var button: Button = item["button"]
			if not button.is_visible_in_tree() or not button.get_global_rect().has_point(event.position):
				continue
			var action: Variant = item["action"]
			if action is Vector2:
				move_touches[event.index] = action
			elif action == "jump":
				_request_jump()
			else:
				_toggle_run()
			get_viewport().set_input_as_handled()
			return
	if event is InputEventScreenDrag and event.index == rotate_touch:
		_orbit(event.relative)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
		_release_camera()

func _unhandled_input(event: InputEvent) -> void:
	if mode != "island":
		return
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_RIGHT:
				rotating_mouse = true
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			MOUSE_BUTTON_WHEEL_UP:
				orbit_distance = maxf(4.5, orbit_distance - 1.15)
			MOUSE_BUTTON_WHEEL_DOWN:
				orbit_distance = minf(22, orbit_distance + 1.15)
	elif event is InputEventMouseMotion and rotating_mouse:
		_orbit(event.relative)
	elif event is InputEventScreenTouch and event.pressed and rotate_touch < 0:
		rotate_touch = event.index
	elif event.is_action_pressed("ui_cancel"):
		_release_camera()

func _process(delta: float) -> void:
	clock += delta
	if mode == "wardrobe":
		var target_rotation := PI if wardrobe_back else 0.0
		target_rotation += sin(clock * 0.85) * 0.28
		art.avatar.rotation.y = lerp_angle(art.avatar.rotation.y, target_rotation, minf(1, delta * 8))
		return
	art.pennant.rotation.y = sin(clock * 2.1) * 0.28
	if mode == "menu":
		var portrait := get_viewport().get_visible_rect().size.x < 640
		camera.position = Vector3(12, 12, 15) if portrait else Vector3(15, 12, 17)
		camera.look_at(Vector3(-2, 0, -4) if portrait else Vector3(2.5, 1.0, -3))
		return

func _physics_process(delta: float) -> void:
	if mode != "island":
		return
	if is_instance_valid(art.shipwalk):
		art.shipwalk.position += Vector3(0, sin(clock * 0.4) * 0.03, 0)
		art._update_shipwalk()
	if biome == 0 and not tondeuse_done:
		_update_tondeuse(delta)
	if biome != 0 and (not started_once or index > 0):
		if not started_once:
			started_once = true
	var left := Input.is_action_pressed("ui_left") or Input.is_action_pressed("move_left") or Input.is_physical_key_pressed(KEY_A) or Input.is_key_pressed(KEY_Q)
	var right_on := Input.is_action_pressed("ui_right") or Input.is_action_pressed("move_right") or Input.is_physical_key_pressed(KEY_D)
	var up := Input.is_action_pressed("ui_up") or Input.is_action_pressed("move_forward") or Input.is_physical_key_pressed(KEY_W) or Input.is_key_pressed(KEY_Z)
	var down := Input.is_action_pressed("ui_down") or Input.is_action_pressed("move_back") or Input.is_physical_key_pressed(KEY_S)
	var direction := Vector2(int(right_on) - int(left), int(down) - int(up)) + movement
	for value in move_touches.values():
		direction += value
	direction = direction.limit_length()
	var forward := Vector3(-sin(orbit_yaw), 0, -cos(orbit_yaw))
	var right := forward.cross(Vector3.UP)
	var motion := right * direction.x - forward * direction.y
	var body: CharacterBody3D = art.avatar
	var before := body.position
	var speed := RUN_SPEED if touch_run or Input.is_key_pressed(KEY_SHIFT) else WALK_SPEED
	var flat_before := Vector3(before.x, 0.0, before.z)
	var target := (flat_before + motion * delta * speed).limit_length(Art.BOUNDS)
	var horizontal := (target - flat_before) / delta
	var vertical := body.velocity.y - GRAVITY * delta
	if jump_requested and body.is_on_floor():
		vertical = JUMP_SPEED
	jump_requested = false
	body.velocity = Vector3(horizontal.x, vertical, horizontal.z)
	body.move_and_slide()
	var position_flat := body.position
	var travelled := position_flat - before
	travelled.y = 0
	if travelled.length() > 0.005:
		body.rotation.y = lerp_angle(body.rotation.y, atan2(-travelled.x, -travelled.z), minf(1, delta * 13))
	if not body.is_on_floor():
		art.arms[0].rotation.x = -0.65
		art.arms[1].rotation.x = -0.65
		art.legs[0].rotation.x = 0.19
		art.legs[1].rotation.x = -0.27
	elif travelled.length() > 0.005:
		for i in range(art.legs.size()):
			art.legs[i].rotation.x = sin(clock * (18 if speed == RUN_SPEED else 13) + i * PI) * 0.48
			art.arms[i].rotation.x = -art.legs[i].rotation.x * 0.75
	else:
		for leg in art.legs:
			leg.rotation.x = 0
		for arm in art.arms:
			arm.rotation.x = 0
	_update_camera()
	var distance: float = position_flat.distance_to(art.flag.position)
	var displacement: Vector3 = art.flag.position - position_flat
	var forward_distance := forward.dot(displacement)
	var right_distance := right.dot(displacement)
	var bearing := "tout droit" if forward_distance >= 0 else "vers le bas"
	if absf(right_distance) > absf(forward_distance):
		bearing = "à droite" if right_distance > 0 else "à gauche"
	play_target.text = "%d m • %s" % [ceili(distance), bearing]
	if body.is_on_floor() and (biome != 0 or tondeuse_done) and distance < 1.85:
		_show_question()

func _show_question() -> void:
	question = Adaptive.pick_question(domain, seen)
	if question.is_empty():
		_finish()
		return
	seen.append(question["id"])
	_new_screen("quiz")
	art.flag.hide()
	quiz = _scroll()
	var header := _flow()
	quiz.add_child(header)
	_button(header, "Retour au menu", _back)
	var progress := UI.label("DRAPEAU %02d / %02d" % [index + 1, TOTAL], 15, UI.BLUE)
	progress.custom_minimum_size.x = 150
	header.add_child(progress)
	var track := ProgressBar.new()
	track.max_value = TOTAL
	track.value = index + 1
	track.show_percentage = false
	track.custom_minimum_size.y = 8
	track.add_theme_stylebox_override("background", UI.surface(Color("#e3edf9"), 5, 0))
	track.add_theme_stylebox_override("fill", UI.surface(Color("#338f81"), 5, 0))
	quiz.add_child(track)
	quiz.add_child(UI.label("DRAPEAU TROUVÉ   /   " + str(question["skill"]).to_upper(), 14, UI.BLUE))
	quiz.add_child(UI.label(question["question"], 27))
	quiz.add_child(UI.label("Prends ton temps, il n’y a pas de chrono.", 16, UI.MUTED))
	var options: Array = question["answers"].duplicate()
	var solution: String = str(options[question["correct"]])
	options.shuffle()
	correct_slot = options.find(solution)
	if correct_slot == last_slot and options.size() > 1:
		var alternate := (correct_slot + randi_range(1, options.size() - 1)) % options.size()
		var misplaced: Variant = options[alternate]
		options[alternate] = solution
		options[correct_slot] = misplaced
		correct_slot = alternate
	last_slot = correct_slot
	buttons.clear()
	for slot in range(options.size()):
		var text := "%s.  %s" % [char(65 + slot), options[slot]]
		var option := _button(quiz, text, _answer.bind(slot))
		option.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		option.keep_pressed_outside = false
		option.alignment = HORIZONTAL_ALIGNMENT_LEFT
		buttons.append(option)
	var helpers := _flow()
	quiz.add_child(helpers)
	_button(helpers, "Indice", _hint)
	_button(helpers, "Explication", _explain)
	_button(helpers, "Vidéo", _video)
	_button(helpers, "Passer", func(): _answer(-1))
	hint = UI.label("", 17, UI.MUTED)
	hint.hide()
	quiz.add_child(hint)
	_resize()

func _hint() -> void:
	hint.text = "Indice : " + str(question.get("hint", "Cherche d’abord ce qu’on te demande."))
	hint.show()

func _explain() -> void:
	if mode == "quiz":
		_hint()
		Speech.speak(hint.text)
	elif mode == "feedback":
		Speech.speak(info.text)

func _video() -> void:
	var url: String = str(question.get("videoUrl", ""))
	if not url.begins_with("https://"):
		url = "https://www.lumni.fr/primaire/cm2/mathematiques"
	OS.shell_open(url)

func _answer(slot: int) -> void:
	if mode != "quiz":
		return
	var right_answer := slot == correct_slot
	var gained := 0
	if slot >= 0:
		attempts += 1
		GameState.record_answer(question["domain"], right_answer)
	if right_answer:
		score += 1
		gained = question.get("reward", 10)
		earned += gained
		Wallet.add(gained)
		GameState.add_xp(gained)
		if Wallet.get_balance() >= Wallet.MULTIPLAYER_UNLOCK_COST:
			GameState.state["unlockedMultiplayer"] = true
			GameState.save()
	_new_screen("feedback")
	var content := _scroll()
	content.add_child(UI.label("DRAPEAU %02d / %02d   —   CORRECTION" % [index + 1, TOTAL], 14, UI.BLUE))
	content.add_child(UI.label(question["question"], 26))
	var solution: String = question["answers"][question["correct"]]
	var panel := UI.card(UI.MINT if right_answer else Color("#fff0cb"), 14)
	content.add_child(panel)
	var group := UI.column(8)
	panel.add_child(group)
	var title := "Bien joué ! +%d %s" % [gained, ShopDB.CURRENCY] if right_answer else "Regardons la méthode ensemble."
	group.add_child(UI.label(title, 21))
	group.add_child(UI.label("Bonne réponse : " + solution, 18))
	info = UI.label(str(question.get("explanation", "")), 17)
	group.add_child(info)
	next = _button(content, "Suivant" if index + 1 < TOTAL else "Voir le bilan", _advance, true)
	var helpers := _flow()
	content.add_child(helpers)
	_button(helpers, "Écouter l’explication", _explain)
	_button(helpers, "Vidéo", _video)

func _advance() -> void:
	if mode != "feedback":
		return
	index += 1
	if index >= TOTAL:
		_finish()
	else:
		_show_island()

func _finish() -> void:
	_new_screen("finish")
	if attempts > 0:
		var history: Array = GameState.state["leaderboard"]
		history.append({"score": score, "date": Time.get_date_string_from_system()})
		history.sort_custom(func(a, b): return a["score"] > b["score"])
		if history.size() > 10:
			history.resize(10)
		GameState.save()
	var content := _scroll()
	content.add_child(UI.label("MISSION TERMINÉE", 14, UI.BLUE))
	content.add_child(UI.label("Bravo pour ton exploration !", 30))
	content.add_child(UI.label("%d bonnes réponses et %d %s gagnés." % [score, earned, ShopDB.CURRENCY], 18, UI.MUTED))
	_button(content, "Retour au menu", _back, true)

func _wardrobe(message: String = "") -> void:
	if not art.preview_only:
		_set_world(0, true)
		wardrobe_back = false
	var scroll_y := wardrobe_scroll.scroll_vertical if is_instance_valid(wardrobe_scroll) else 0
	_new_screen("wardrobe")
	wardrobe_scroll = ScrollContainer.new()
	wardrobe_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	screen.add_child(wardrobe_scroll)
	var panel := UI.card()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wardrobe_scroll.add_child(panel)
	var content := UI.column(8)
	panel.add_child(content)
	content.add_child(UI.label("L’atelier d’Arthur", 28))
	content.add_child(UI.label("%d %s disponibles" % [Wallet.get_balance(), ShopDB.CURRENCY], 16, UI.BLUE))
	var actions := _flow()
	content.add_child(actions)
	_button(actions, "Menu", _menu)
	_button(actions, "Tourner Arthur", func(): wardrobe_back = not wardrobe_back)
	if not message.is_empty():
		content.add_child(UI.label(message, 15, UI.MUTED))
	var owned: Array = GameState.state.get("adventure_owned", [])
	var equipment: Dictionary = GameState.state.get("adventure_equipment", {})
	for item in ShopDB.GEAR:
		var title: String = item["name"]
		var equipped: bool = equipment.get(item["slot"], "") == item["id"]
		var status := "Retirer" if equipped else ("Équiper" if owned.has(item["id"]) else "%d %s" % [item["price"], ShopDB.CURRENCY])
		var entry := _button(content, "%s  —  %s" % [title, status], _change_gear.bind(item["id"], title))
		entry.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_resize()
	wardrobe_scroll.set_deferred("scroll_vertical", scroll_y)

func _change_gear(id: String, title: String) -> void:
	if ShopDB.change_gear(GameState.state, id):
		GameState.save()
		wardrobe_back = id in ["cape", "pack"]
		art.refresh_gear()
		_wardrobe("Tenue mise à jour : " + title + ".")
	else:
		_wardrobe("Il te manque des Arthéons pour cet équipement.")

func _scores() -> void:
	_new_screen("scores")
	var content := _scroll()
	content.add_child(UI.label("Mes scores", 28))
	var history: Array = GameState.state["leaderboard"]
	if history.is_empty():
		content.add_child(UI.label("Termine une aventure pour voir ton premier score ici.", 17, UI.MUTED))
	for entry in history:
		content.add_child(UI.label("%d bonnes réponses  —  %s" % [entry["score"], str(entry["date"]).left(10)]))
	_button(content, "Retour au menu", _menu, true)

func _back() -> void:
	Speech.stop()
	get_tree().change_scene_to_file(MENU)

func _resize() -> void:
	var width := get_viewport().get_visible_rect().size.x
	if mode == "wardrobe" and is_instance_valid(wardrobe_scroll):
		var portrait := width < 680
		wardrobe_scroll.anchor_bottom = 1
		wardrobe_scroll.anchor_right = 1 if portrait else 0
		wardrobe_scroll.anchor_top = 0.42 if portrait else 0
		wardrobe_scroll.offset_left = 14
		wardrobe_scroll.offset_top = 14
		wardrobe_scroll.offset_right = -14 if portrait else 440
		wardrobe_scroll.offset_bottom = -14
		camera.position = Vector3(0, 2.45, -4.2 if portrait else -1.65)
		camera.look_at(Vector3(0, 1.55, 3))
		camera.h_offset = 0 if portrait else -1.6
		camera.v_offset = -2.1 if portrait else 0
		return
	if not is_instance_valid(quiz_card):
		return
	if mode == "menu":
		var size_x := minf(456, width - 28)
		quiz_card.offset_left = 14 if width < 640 else 42
		quiz_card.offset_right = quiz_card.offset_left + size_x
		quiz_card.offset_top = -164
	elif mode in ["quiz", "feedback", "finish", "scores"]:
		quiz_card.custom_minimum_size.x = minf(720, width - 54)
