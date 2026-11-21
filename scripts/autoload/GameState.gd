# GameState.gd - État global du joueur (autoload)
extends Node

const SAVE_PATH = "user://matharthur_save.json"

var state: Dictionary = {}

func _ready():
	randomize()
	_load_or_default()

func _load_or_default():
	var f = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f:
		var txt = f.get_as_text()
		f.close()
		var parsed = JSON.parse_string(txt)
		if parsed is Dictionary:
			state = parsed
			_merge_defaults()
			return
	state = _default_state()
	_merge_defaults()

func _default_state() -> Dictionary:
	return {
		"player": {"name":"Chevalier","level":1,"xp":0,"avatar":"av1","hat":"","pet":"","bg":"b1","effect":""},
		"wallet": 0,
		"owned": {"avatars":["av1"],"hats":[],"pets":[],"backgrounds":["b1"],"effects":[]},
		"equipped": {"avatar":"av1","hat":"","pet":"","bg":"b1","effect":""},
		"stats": {"correct":0,"wrong":0,"streak":0,"bestStreak":0,"totalQuestions":0,"byDomain":{}},
		"progress": {},
		"settings": {"sound":true,"speech":true,"video":true,"difficulty":2},
		"leaderboard": [],
		"unlockedMultiplayer": false,
		"dailyChallenge": null,
		"lastVisit": null
	}

func _merge_defaults():
	var d = _default_state()
	for k in d.keys():
		if not state.has(k):
			state[k] = d[k]
	if not state["player"].has("name"): state["player"]["name"]="Chevalier"
	if not state["owned"].has("avatars"): state["owned"]["avatars"]=["av1"]
	if not state["owned"].has("backgrounds"): state["owned"]["backgrounds"]=["b1"]

func save():
	var f = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(state))
		f.close()

func get_domain_progress(domain: String) -> Dictionary:
	if not state["progress"].has(domain):
		state["progress"][domain] = {"completed":0,"mastery":0.0,"attempts":0,"correct":0}
	return state["progress"][domain]

func add_xp(amount: int) -> Dictionary:
	state["player"]["xp"] += amount
	var needed = state["player"]["level"] * 100
	var leveled = false
	while state["player"]["xp"] >= needed:
		state["player"]["xp"] -= needed
		state["player"]["level"] += 1
		leveled = true
		needed = state["player"]["level"] * 100
	save()
	return {"leveled": leveled, "level": state["player"]["level"]}

func add_wallet(amount: int):
	state["wallet"] += amount
	save()

func spend_wallet(amount: int) -> bool:
	if state["wallet"] >= amount:
		state["wallet"] -= amount
		save()
		return true
	return false

func record_answer(domain: String, correct: bool):
	var s = state["stats"]
	s["totalQuestions"] += 1
	if correct:
		s["correct"] += 1
		s["streak"] += 1
		if s["streak"] > s["bestStreak"]:
			s["bestStreak"] = s["streak"]
	else:
		s["wrong"] += 1
		s["streak"] = 0
	# domain stats
	if not s["byDomain"].has(domain):
		s["byDomain"][domain] = {"correct":0,"wrong":0}
	if correct: s["byDomain"][domain]["correct"] += 1
	else: s["byDomain"][domain]["wrong"] += 1
	# progress mastery
	var p = get_domain_progress(domain)
	p["attempts"] += 1
	if correct: p["correct"] += 1
	var acc = float(p["correct"]) / float(p["attempts"])
	p["mastery"] = 0.7 * p["mastery"] + 0.3 * acc
	save()
	return s["streak"]
