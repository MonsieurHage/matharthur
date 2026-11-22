# Speech.gd - Synthèse vocale (explication orale)
# Désactivée par défaut : la TTS Windows peut provoquer des crashes mémoire
# avec le rendu gl_compatibility. Le réglage utilisateur peut la réactiver.
extends Node

var voices: Array = []
var current_voice: String = ""
var enabled := false

func _ready():
	if not ProjectSettings.get_setting("audio/general/text_to_speech", false):
		return
	voices = DisplayServer.tts_get_voices()
	# préférer une voix française
	for v in voices:
		if "fr" in v.get("language", "").to_lower() or "french" in v.get("name", "").to_lower():
			current_voice = v.get("id", "")
			break
	if current_voice == "" and voices.size() > 0:
		current_voice = voices[0].get("id", "")
	enabled = not current_voice.is_empty()

func speak(text: String, rate: float = 1.0):
	if not enabled or not GameState.state["settings"]["speech"]:
		return
	DisplayServer.tts_speak(text, current_voice, 65, 1.0, rate, 0, true)

func stop():
	if enabled:
		DisplayServer.tts_stop()

func is_available() -> bool:
	return enabled
