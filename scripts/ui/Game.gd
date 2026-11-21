# Game.gd
extends Node3D

const TOTAL_QUESTIONS = 10

@onready var question_text = $UI/Root/VBox/Scroll/Content/QuestionCard/VBox/QuestionText
@onready var domain_tag = $UI/Root/VBox/Scroll/Content/QuestionCard/VBox/DomainTag
@onready var answers_grid = $UI/Root/VBox/Scroll/Content/QuestionCard/VBox/Answers
@onready var hint_area = $UI/Root/VBox/Scroll/Content/QuestionCard/VBox/HintArea
@onready var progress_bar = $UI/Root/VBox/TopBar/ProgressWrap/ProgressBar
@onready var progress_text = $UI/Root/VBox/TopBar/ProgressWrap/ProgressText
@onready var wallet_label = $UI/Root/VBox/TopBar/Wallet
@onready var encouragement_label = $UI/Root/VBox/Scroll/Content/SidePanel/Encouragement
@onready var combo_label = $UI/Root/VBox/Scroll/Content/SidePanel/Row/Combo
@onready var timer_label = $UI/Root/VBox/Scroll/Content/SidePanel/Row/Timer
@onready var feedback_panel = $UI/Feedback
@onready var feedback_emoji = $UI/Feedback/VBox/Emoji
@onready var feedback_text = $UI/Feedback/VBox/Text
@onready var feedback_reward = $UI/Feedback/VBox/Reward

var domain: String = "Nombres et calculs"
var current_question: Dictionary = {}
var question_index: int = 0
var correct_count: int = 0
var excluded_ids: Array = []
var time_left: float = 30.0
var timer_running: bool = false
var answered: bool = false
var combo: int = 0
var scaffold_level: int = 0

func _ready():
	domain = GameState.state.get("currentDomain", Adaptive.weakest_domain())
	var helpers = $UI/Root/VBox/Scroll/Content/SidePanel/Helpers
	$UI/Root/VBox/TopBar/BackBtn.pressed.connect(_on_back)
	helpers.get_node("HintBtn").pressed.connect(_on_hint)
	helpers.get_node("ExplainBtn").pressed.connect(_on_explain)
	helpers.get_node("VideoBtn").pressed.connect(_on_video)
	helpers.get_node("SkipBtn").pressed.connect(_on_skip)
	$UI/Feedback/VBox/Actions/NextBtn.pressed.connect(_on_next)
	$UI/Feedback/VBox/Actions/ExplainAfterBtn.pressed.connect(_on_explain)
	_update_wallet()
	_load_question()

func _process(delta):
	if timer_running and not answered:
		time_left -= delta
		timer_label.text = "⏱️ " + str(int(ceil(time_left)))
		if time_left <= 5:
			timer_label.modulate = Color(1,0.3,0.3)
		if time_left <= 0:
			time_left = 0
			_on_timeout()

func _load_question():
	if question_index >= TOTAL_QUESTIONS:
		_end_game()
		return
	current_question = Adaptive.pick_question(domain, excluded_ids)
	if current_question.is_empty():
		_end_game(); return
	excluded_ids.append(current_question["id"])
	question_text.text = current_question["question"]
	domain_tag.text = current_question["domain"] + " • " + current_question["skill"]
	# answers
	for c in answers_grid.get_children():
		c.queue_free()
	var answers = current_question["answers"]
	for i in range(answers.size()):
		var b = Button.new()
		b.text = str(answers[i])
		b.custom_minimum_size = Vector2(200, 60)
		b.pressed.connect(func(): _on_answer(i, b))
		answers_grid.add_child(b)
	hint_area.visible = false
	hint_area.text = ""
	time_left = 30.0
	timer_running = true
	answered = false
	scaffold_level = 0
	progress_bar.value = question_index
	progress_text.text = str(question_index) + "/" + str(TOTAL_QUESTIONS)
	combo_label.text = "Combo x" + str(combo+1)
	encouragement_label.text = Encouragement.get("welcome") if question_index==0 else Encouragement.get("correct") if combo>0 else "Tu peux le faire ! 💪"
	Speech.speak(current_question["question"])

func _on_answer(idx: int, btn: Button):
	if answered: return
	answered = true
	timer_running = false
	var correct_idx = current_question["correct"]
	var is_correct = (idx == correct_idx)
	# highlight
	for i in range(answers_grid.get_child_count()):
		var b = answers_grid.get_child(i)
		if i == correct_idx:
			b.modulate = Color(0.4,1,0.4)
		elif i == idx and not is_correct:
			b.modulate = Color(1,0.4,0.4)
	# record
	GameState.record_answer(current_question["domain"], is_correct)
	if is_correct:
		correct_count += 1
		combo += 1
		var reward = current_question.get("reward", 10)
		var bonus = combo * 2
		Wallet.add(reward + bonus, "correct")
		_update_wallet()
		var res = GameState.add_xp(reward + bonus)
		feedback_emoji.text = "✅"
		feedback_text.text = Encouragement.get("correct")
		feedback_reward.text = "+" + str(reward+bonus) + " 🪙  +" + str(reward+bonus) + " XP"
		if combo >= 3:
			feedback_reward.text += "\n" + Encouragement.get("streak", combo)
		if res["leveled"]:
			feedback_reward.text += "\n" + Encouragement.get("levelup", res["level"])
		# confetti
		_spawn_confetti()
		# level up check multiplayer
		if GameState.state["wallet"] >= 500 and not GameState.state["unlockedMultiplayer"]:
			GameState.state["unlockedMultiplayer"] = true
			GameState.save()
			_toast("👥 Multijoueur débloqué !", "gold")
	else:
		combo = 0
		feedback_emoji.text = "❌"
		feedback_text.text = Encouragement.get("wrong")
		feedback_reward.text = "0 🪙"
		# ZPD: scaffolding augmente
		scaffold_level = min(2, scaffold_level+1)
	# update mastery (déjà fait dans record_answer)
	GameState.save()
	feedback_panel.visible = true

func _on_timeout():
	if answered: return
	answered = true
	timer_running = false
	GameState.record_answer(current_question["domain"], false)
	combo = 0
	feedback_emoji.text = "⏰"
	feedback_text.text = "Temps écoulé !"
	feedback_reward.text = "0 🪙"
	for i in range(answers_grid.get_child_count()):
		var b = answers_grid.get_child(i)
		if i == current_question["correct"]:
			b.modulate = Color(0.4,1,0.4)
	feedback_panel.visible = true

func _on_hint():
	if answered: return
	scaffold_level = min(2, scaffold_level+1)
	var h = Adaptive.scaffold(current_question, scaffold_level)
	if h != "":
		hint_area.text = h
		hint_area.visible = true
		Speech.speak(h)
	_toast("Indice utilisé (-2 🪙)", "")
	Wallet.spend(2)

func _on_explain():
	var exp = current_question.get("explanation","")
	# show in a simple popup via toast + speech
	Speech.speak(exp)
	_toast("🔊 " + exp, "")

func _on_video():
	var url = current_question.get("videoUrl", "")
	if url == null or url == "":
		# fallback educational video search by skill
		url = "https://www.youtube.com/results?search_query=maths+cm2+" + current_question["skill"].replace(" ","+")
	_toast("🎬 Ouverture de la vidéo...", "")
	OS.shell_open(url)

func _on_skip():
	if answered: return
	answered = true
	timer_running = false
	GameState.record_answer(current_question["domain"], false)
	combo = 0
	question_index += 1
	_load_question()

func _on_next():
	feedback_panel.visible = false
	question_index += 1
	_load_question()

func _on_back():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _end_game():
	timer_running = false
	var pct = int(float(correct_count)/TOTAL_QUESTIONS*100)
	var msg = "Partie terminée ! Score : " + str(correct_count) + "/" + str(TOTAL_QUESTIONS) + " (" + str(pct) + "%)"
	_toast(msg, "success")
	# update leaderboard
	var lb = GameState.state["leaderboard"]
	lb.append({"name":GameState.state["player"]["name"],"score":correct_count,"date":Time.get_datetime_string_from_system()})
	lb.sort_custom(func(a,b): return a["score"] > b["score"])
	if lb.size() > 10: lb.resize(10)
	GameState.save()
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _update_wallet():
	wallet_label.text = "🪙 " + str(GameState.state["wallet"])

func _toast(msg: String, kind: String):
	# simple print; UI toast could be added
	print("[TOAST] ", msg)

func _spawn_confetti():
	# simple particle burst using a CPUParticles3D
	var p = CPUParticles3D.new()
	p.amount = 60
	p.lifetime = 1.2
	p.explosiveness = 1.0
	p.mesh = SphereMesh.new()
	p.mesh.radius = 0.05
	p.scale_amount_min = 0.5
	p.scale_amount_max = 1.2
	p.direction = Vector3(0,1,0)
	p.spread = 180.0
	p.initial_velocity_min = 3.0
	p.initial_velocity_max = 6.0
	p.gravity = Vector3(0,-9.8,0)
	p.color = Color(1,0.8,0.2,1)
	add_child(p)
	p.emitting = true
	await get_tree().create_timer(1.5).timeout
	p.queue_free()
