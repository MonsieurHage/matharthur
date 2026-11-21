# ShopDB.gd
extends Node

const CURRENCY := "Arthéons"
const GEAR := [
	{"id":"cap", "slot":"head", "name":"Casquette du Cartographe", "price":25},
	{"id":"crown", "slot":"head", "name":"Couronne des Énigmes", "price":100},
	{"id":"cape", "slot":"back", "name":"Cape de l’Aurore", "price":50},
	{"id":"pack", "slot":"back", "name":"Sac des Explorateurs", "price":75},
	{"id":"compass", "slot":"badge", "name":"Insigne de la Boussole", "price":30},
	{"id":"crystal", "slot":"badge", "name":"Insigne du Cristal", "price":65},
]

# Apply to a profile, then the caller saves once. Old balances remain valid.
func change_gear(profile: Dictionary, id: String) -> bool:
	for item in GEAR:
		if item["id"] != id:
			continue
		var owned: Array = profile.get("adventure_owned", [])
		var equipment: Dictionary = profile.get("adventure_equipment", {})
		if not owned.has(id):
			if int(profile["wallet"]) < item["price"]:
				return false
			profile["wallet"] -= item["price"]
			owned.append(id)
		var slot: String = item["slot"]
		if equipment.get(slot, "") == id:
			equipment.erase(slot)
		else:
			equipment[slot] = id
		profile["adventure_owned"] = owned
		profile["adventure_equipment"] = equipment
		return true
	return false

const CATEGORIES = [
	{"key":"avatars","label":"Personnages","icon":"🧙"},
	{"key":"hats","label":"Chapeaux","icon":"🎩"},
	{"key":"pets","label":"Compagnons","icon":"🐾"},
	{"key":"backgrounds","label":"Fonds","icon":"🖼️"},
	{"key":"effects","label":"Effets","icon":"✨"},
]

const ITEMS = {
	"avatars": [
		{"id":"av1","name":"Magicien","icon":"🧙‍♂️","price":0,"owned":true},
		{"id":"av2","name":"Chevalier","icon":"🧝‍♂️","price":50},
		{"id":"av3","name":"Princesse","icon":"👸","price":80},
		{"id":"av4","name":"Dragon","icon":"🐉","price":200},
		{"id":"av5","name":"Robot","icon":"🤖","price":150},
		{"id":"av6","name":"Astronaute","icon":"👨‍🚀","price":120},
		{"id":"av7","name":"Ninja","icon":"🥷","price":180},
		{"id":"av8","name":"Roi","icon":"👑","price":300},
	],
	"hats": [
		{"id":"h1","name":"Chapeau","icon":"🎩","price":30},
		{"id":"h2","name":"Couronne","icon":"👑","price":100},
		{"id":"h3","name":"Casque","icon":"⛑️","price":60},
		{"id":"h4","name":"Béret","icon":"🫖","price":25},
		{"id":"h5","name":"Bandeau","icon":"🥽","price":40},
	],
	"pets": [
		{"id":"p1","name":"Chat","icon":"🐱","price":80},
		{"id":"p2","name":"Chien","icon":"🐶","price":80},
		{"id":"p3","name":"Hibou","icon":"🦉","price":120},
		{"id":"p4","name":"Licorne","icon":"🦄","price":250},
		{"id":"p5","name":"Dragonnet","icon":"🐲","price":300},
	],
	"backgrounds": [
		{"id":"b1","name":"Château","icon":"🏰","price":0,"owned":true},
		{"id":"b2","name":"Forêt","icon":"🌲","price":60},
		{"id":"b3","name":"Espace","icon":"🌌","price":120},
		{"id":"b4","name":"Océan","icon":"🌊","price":90},
		{"id":"b5","name":"Désert","icon":"🏜️","price":70},
	],
	"effects": [
		{"id":"e1","name":"Étincelles","icon":"✨","price":150},
		{"id":"e2","name":"Feu","icon":"🔥","price":200},
		{"id":"e3","name":"Glace","icon":"❄️","price":180},
	],
}

func is_owned(cat: String, id: String) -> bool:
	return GameState.state["owned"][cat].has(id)

func buy(cat: String, id: String) -> bool:
	for it in ITEMS[cat]:
		if it["id"] == id:
			if is_owned(cat, id): return true
			if Wallet.spend(it["price"]):
				GameState.state["owned"][cat].append(id)
				GameState.save()
				return true
			return false
	return false
