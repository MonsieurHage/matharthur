# Wallet.gd - Porte-monnaie
extends Node

const MULTIPLAYER_UNLOCK_COST = 500

func get() -> int:
	return GameState.state["wallet"]

func add(amount: int, reason: String = ""):
	GameState.add_wallet(amount)
	# notification gérée par l'UI

func spend(amount: int) -> bool:
	return GameState.spend_wallet(amount)

func can_unlock_multiplayer() -> bool:
	return get() >= MULTIPLAYER_UNLOCK_COST

func unlock_multiplayer() -> bool:
	if can_unlock_multiplayer() and not GameState.state["unlockedMultiplayer"]:
		if spend(MULTIPLAYER_UNLOCK_COST):
			GameState.state["unlockedMultiplayer"] = true
			GameState.save()
			return true
	return GameState.state["unlockedMultiplayer"]
