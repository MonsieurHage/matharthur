# Speech.gd - Synthèse vocale (explication orale)
extends Node

var voices: Array = []
var current_voice: String = ""

func _ready():
	voices = DisplayServer.tts_get_voices()
	# préférer une voix française
	for v in voices:
		if "fr" in v.get("language","").to_lower() or "french" in v.get("name","").to_lower():
			current_voice = v.get("id","")
			break
	if current_voice == "" and voices.size() > 0:
		current_voice = voices[0].get("id","")

func speak(text: String, rate: float = 1.0):
	if not GameState.state["settings"]["speech"]:
		return
	DisplayServer.tts_speak(text, current_voice, 50, rate, 1.0, 0)

func stop():
	DisplayServer.tts_stop()

func is_available() -> bool:
	return voices.size() > 0
