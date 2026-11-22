extends Node

const MENU := preload("res://scenes/MainMenu.tscn")
var adventure: Node3D
var failures := 0

func _ready() -> void:
	adventure = MENU.instantiate()
	add_child(adventure)
	await _capture("menu")
	_check(adventure.mode == "menu", "Ouverture du menu")
	var profile := {"wallet": 29}
	_check(not ShopDB.change_gear(profile, "crown"), "Achat refusé si le solde est insuffisant")
	_check(ShopDB.change_gear(profile, "cap") and profile["wallet"] == 4, "Achat débité une fois")
	_check(profile["adventure_equipment"].get("head") == "cap", "Équipement automatique")
	_check(ShopDB.change_gear(profile, "cap") and profile["adventure_equipment"].is_empty(), "Retrait sans perte d’achat")
	_check(ShopDB.change_gear(profile, "cap") and profile["wallet"] == 4, "Rééquiper ne coûte rien")
	adventure._wardrobe()
	await _capture("atelier")
	_check(adventure.mode == "wardrobe" and adventure.art.preview_only, "Atelier avec aperçu 3D")
	adventure._menu()
	var checkpoints := {}
	for i in range(1, Adaptive.DOMAINS.size()):
		adventure._start(Adaptive.DOMAINS[i])
		_check(adventure.art.biome == i, "Le thème sélectionné change la carte")
		var location: Vector3 = adventure.art.target_at(9)
		_check(location.length() > 25 and not checkpoints.has(location), "Grande carte et parcours distinct")
		checkpoints[location] = true
		var theme: String = Adaptive.DOMAINS[i]
		var bank: Array = QuestionsDB.ALL.filter(func(question): return question["domain"] == theme)
		_check(bank.size() >= adventure.TOTAL, "Le thème propose dix questions différentes")
		await _capture("carte-%s" % i)
	adventure._start("Nombres et calculs")
	adventure.tondeuse_seen = true
	adventure.tondeuse_done = true
	await _capture("ile")
	_check(adventure.mode == "island" and adventure.seen.is_empty(), "Aucune question avant le drapeau")
	await _check_controls()
	await _check_obstacle()
	var previous := -1
	for i in range(adventure.TOTAL):
		adventure.art.avatar.position = adventure.art.flag.position + Vector3(0, 0, 1.72)
		await get_tree().physics_frame
		await get_tree().physics_frame
		_check(adventure.mode == "quiz", "Le drapeau ouvre le quiz %s" % (i + 1))
		if adventure.mode != "quiz":
			break
		_check(adventure.screen.get_child_count() == 2, "Le quiz est indépendant des commandes")
		_check(adventure.correct_slot != previous, "La bonne réponse change de place")
		previous = adventure.correct_slot
		var question: Dictionary = adventure.question
		var correct_text: String = question["answers"][question["correct"]]
		_check(adventure.buttons[previous].text.ends_with(correct_text), "Correction préservée")
		adventure._hint()
		_check(adventure.hint.visible, "Indice gratuit et visible")
		if i == 0:
			await _capture("quiz")
		adventure._answer(-1)
		_check(adventure.mode == "feedback" and adventure.next.visible, "Le bouton Suivant est visible")
		if i == 0:
			await _capture("correction")
		adventure._advance()
	_check(adventure.mode == "finish", "Bilan directement après la dernière question")
	adventure.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	print("MathArthur — %d erreur(s)" % failures)
	get_tree().quit(1 if failures else 0)

func _check_controls() -> void:
	var body: CharacterBody3D = adventure.art.avatar
	var spawn := Vector3(0, 0, 3)
	var starting_yaw: float = adventure.orbit_yaw
	adventure._orbit(Vector2(50, 20))
	_check(not is_equal_approx(adventure.orbit_yaw, starting_yaw), "La souris fait pivoter la caméra")
	adventure.orbit_yaw = starting_yaw
	var starting_zoom: float = adventure.orbit_distance
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel.pressed = true
	adventure._unhandled_input(wheel)
	_check(adventure.orbit_distance < starting_zoom, "La molette rapproche la caméra")
	adventure.orbit_distance = starting_zoom
	body.position = spawn
	adventure.movement = Vector2.DOWN
	for i in range(8):
		await get_tree().physics_frame
	var walk_distance := body.position.distance_to(spawn)
	body.position = spawn
	adventure._toggle_run()
	for i in range(8):
		await get_tree().physics_frame
	var run_distance := body.position.distance_to(spawn)
	_check(run_distance > walk_distance * 1.35, "La course est plus rapide que la marche")
	adventure.movement = Vector2.ZERO
	adventure._toggle_run()
	body.position = spawn
	await get_tree().physics_frame
	await get_tree().physics_frame
	var jump_event := InputEventAction.new()
	jump_event.action = "jump"
	jump_event.pressed = true
	adventure._input(jump_event)
	var highest := 0.0
	for i in range(60):
		await get_tree().physics_frame
		highest = maxf(highest, body.position.y)
	_check(highest > 0.8, "Le saut décolle du sol")
	_check(body.is_on_floor() and absf(body.position.y) < 0.12, "Arthur retombe au sol après le saut")

func _check_obstacle() -> void:
	# Start in front of the left tower and try to cross it at running speed.
	var body: CharacterBody3D = adventure.art.avatar
	body.position = Vector3(-14, 0, -1)
	await get_tree().physics_frame
	var impact := body.move_and_collide(Vector3(0, 0, -8))
	_check(impact != null and body.position.z > -5, "Arthur est arrêté par la tour")
	# Beside it, the same sweep should cover the full distance.
	# Use a shorter, measured segment to avoid unrelated vegetation.
	body.position = Vector3(-11.8, 0, -4)
	await get_tree().physics_frame
	var origin := body.position
	body.move_and_collide(Vector3(0, 0, -2))
	_check(body.position.distance_to(origin) > 1.9, "Arthur peut contourner la tour")

func _check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error(description)

func _capture(name_value: String) -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty() or DisplayServer.get_name() == "headless":
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(args[0] + "/" + name_value + ".png")
