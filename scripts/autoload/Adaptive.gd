# Adaptive.gd - Moteur d'adaptive learning (ZPD)
extends Node

const DOMAINS = ["Nombres et calculs","Géométrie","Grandeurs et mesures","Organisation et gestion de données"]

func target_difficulty(domain: String) -> int:
	var gs = GameState.state
	var p = GameState.get_domain_progress(domain)
	var mastery = p["mastery"]
	var streak = gs["stats"]["streak"]
	var d = 1 + int(round(mastery * 4.0))  # 1..5
	d = min(5, d + 1)  # ZPD : juste au-dessus
	if streak >= 5: d = min(5, d + 1)
	if streak == 0 and gs["stats"]["wrong"] > gs["stats"]["correct"]: d = max(1, d - 1)
	d = int(round((d + (gs["settings"]["difficulty"])) / 2.0))
	return clamp(d, 1, 5)

func pick_question(domain: String, exclude: Array) -> Dictionary:
	var target = target_difficulty(domain if domain != "Tous" else DOMAINS[0])
	var pool: Array = []
	for q in QuestionsDB.ALL:
		if exclude.has(q["id"]): continue
		if domain != "Tous" and q["domain"] != domain: continue
		pool.append(q)
	# opérations générées
	if (domain == "Nombres et calculs" or domain == "Tous") and randf() < 0.35:
		pool.append(QuestionsDB.gen_operation(target))
	var candidates = pool.filter(func(q): return abs(q["difficulty"] - target) <= 1)
	if candidates.is_empty(): candidates = pool
	if candidates.is_empty(): return {}
	return candidates[randi() % candidates.size()]

func scaffold(question: Dictionary, level: int) -> String:
	if level == 1: return question.get("hint","")
	if level == 2: return "Indice : " + question.get("hint","") + " | Réponse proche de " + str(question["answers"][question["correct"]])
	return ""

func weakest_domain() -> String:
	var minm = 1.0
	var dom = DOMAINS[0]
	for d in DOMAINS:
		var m = GameState.get_domain_progress(d)["mastery"]
		if m < minm:
			minm = m
			dom = d
	return dom
