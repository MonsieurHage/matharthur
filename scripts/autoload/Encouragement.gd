# Encouragement.gd
extends Node

const DATA = {
	"correct": ["Bravo champion !","Excellent ! Tu es un vrai chevalier !","Magnifique ! Continue comme ça !","Super ! Tu maîtrises bien ça !","Fantastique ! Le royaume est fier de toi !","Parfait ! Tu progresses à vitesse grand V !","Incroyable ! Encore un point pour le héros !","Bravo ! Ton intelligence brille !","Génial ! Tu es sur la bonne voie !","Oui ! Continue, tu es unstoppable !"],
	"wrong": ["Pas grave, on réessaie !","Presque ! Tu vas y arriver !","Courage, chaque erreur est un apprentissage !","Ne te décourage pas !","C'est en forgeant qu'on devient forgeron !","Essaie encore, tu es capable !","Pas de panique, l'erreur fait partie du jeu !"],
	"streak": ["🔥 Série de {n} ! Tu es en feu !","⚡ {n} bonnes réponses d'affilée !","🌟 Combo x{n} ! Le royaume tremble !"],
	"levelup": ["🎉 NIVEAU SUPÉRIEUR ! Niveau {n} !","👑 Félicitations ! Niveau {n} atteint !"],
	"welcome": ["Bienvenue dans le Royaume des Maths !","Prêt à conquérir les nombres ?"]
}

func get_message(kind: String, n: int = 0) -> String:
	var arr = DATA.get(kind, DATA["correct"])
	var s = arr[randi() % arr.size()]
	if "{n}" in s: s = s.replace("{n}", str(n))
	return s
