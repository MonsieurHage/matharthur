# QuestionsDB.gd - Banque de questions CM2
extends Node

var ALL: Array = []

func _init_db():
	if ALL.size() > 0: return
	var raw = [
		# Nombres et calculs - Grands nombres
		{"domain":"Nombres et calculs","skill":"Grands nombres","difficulty":2,"question":"Comment écrit-on 'trois millions quatre cent vingt mille quinze' ?","answers":["3 420 015","3 042 015","3 402 015","3 420 150"],"correct":0,"explanation":"3 420 015","hint":"Décompose par millions, milliers, unités.","reward":20},
		{"domain":"Nombres et calculs","skill":"Grands nombres","difficulty":2,"question":"Quel est le chiffre des dizaines de mille dans 4 587 231 ?","answers":["8","5","7","2"],"correct":0,"explanation":"Le chiffre des dizaines de mille est 8.","hint":"Compte les positions depuis la droite.","reward":20},
		{"domain":"Nombres et calculs","skill":"Grands nombres","difficulty":2,"question":"Combien vaut 7 millions + 45 mille + 3 ?","answers":["7 045 003","7 450 003","7 004 503","7 405 003"],"correct":0,"explanation":"7 045 003.","hint":"Aligne les nombres.","reward":20},
		{"domain":"Nombres et calculs","skill":"Grands nombres","difficulty":1,"question":"Quel nombre est le plus grand ?","answers":["4 500 000","4 050 000","4 005 000","4 000 500"],"correct":0,"explanation":"4 500 000.","hint":"Compare chiffre par chiffre depuis la gauche.","reward":15},
		{"domain":"Nombres et calculs","skill":"Grands nombres","difficulty":3,"question":"Décomposer 6 304 218.","answers":["6 millions, 304 milliers, 218","6 millions, 300 milliers, 4218","6 millions, 304 mille, 218","6 M, 304 k, 218"],"correct":2,"explanation":"6 millions, 304 milliers, 218.","hint":"Groupes de 3 chiffres.","reward":25},
		{"domain":"Nombres et calculs","skill":"Grands nombres","difficulty":1,"question":"Combien de zéros dans un million ?","answers":["6","5","7","9"],"correct":0,"explanation":"6 zéros.","hint":"1 000 000.","reward":15},
		{"domain":"Nombres et calculs","skill":"Grands nombres","difficulty":2,"question":"Écrire en chiffres : quatre-vingt-dix mille six cent douze.","answers":["90 612","80 912","90 600 12","980 612"],"correct":0,"explanation":"90 612.","hint":"quatre-vingt-dix = 90.","reward":20},
		{"domain":"Nombres et calculs","skill":"Grands nombres","difficulty":3,"question":"Quel est le rang du chiffre 3 dans 2 345 678 ?","answers":["centaines de mille","dizaines de mille","millions","milliers"],"correct":0,"explanation":"centaines de mille.","hint":"Positions : ... millions, centaines de mille...","reward":25},
		# Multiples et diviseurs
		{"domain":"Nombres et calculs","skill":"Multiples et diviseurs","difficulty":3,"question":"Quel est le plus petit multiple commun de 4 et 6 ?","answers":["12","24","6","4"],"correct":0,"explanation":"PPCM(4,6)=12.","hint":"Liste les multiples.","reward":25},
		{"domain":"Nombres et calculs","skill":"Multiples et diviseurs","difficulty":2,"question":"36 est-il divisible par 9 ?","answers":["Oui","Non"],"correct":0,"explanation":"36/9=4.","hint":"9×4=36.","reward":20},
		{"domain":"Nombres et calculs","skill":"Multiples et diviseurs","difficulty":3,"question":"Quels sont les diviseurs de 12 ?","answers":["1,2,3,4,6,12","1,2,4,6,12","1,3,4,12","2,3,4,6"],"correct":0,"explanation":"1,2,3,4,6,12.","hint":"Un diviseur divise sans reste.","reward":25},
		{"domain":"Nombres et calculs","skill":"Multiples et diviseurs","difficulty":2,"question":"Lequel est un multiple de 7 ?","answers":["49","50","48","56? non"],"correct":0,"explanation":"49=7×7.","hint":"7×7=49.","reward":20},
		{"domain":"Nombres et calculs","skill":"Multiples et diviseurs","difficulty":4,"question":"PGCD de 18 et 24 ?","answers":["6","3","12","2"],"correct":0,"explanation":"PGCD(18,24)=6.","hint":"Diviseurs communs.","reward":30},
		{"domain":"Nombres et calculs","skill":"Multiples et diviseurs","difficulty":2,"question":"Un nombre divisible par 2 et par 5 est divisible par ?","answers":["10","20","7","3"],"correct":0,"explanation":"10.","hint":"2×5=10.","reward":20},
		# Fractions
		{"domain":"Nombres et calculs","skill":"Fractions","difficulty":1,"question":"Quelle fraction représente la moitié ?","answers":["1/2","1/3","2/1","1/4"],"correct":0,"explanation":"1/2.","hint":"Moitié = 1 sur 2.","reward":15},
		{"domain":"Nombres et calculs","skill":"Fractions","difficulty":2,"question":"1/4 + 1/4 = ?","answers":["1/2","2/4","1/8","2/8"],"correct":0,"explanation":"1/2 (ou 2/4).","hint":"Même dénominateur.","reward":20},
		{"domain":"Nombres et calculs","skill":"Fractions","difficulty":3,"question":"Quelle est la fraction décimale de 0,75 ?","answers":["75/100","7/10","3/4","75/10"],"correct":0,"explanation":"75/100.","hint":"2 décimales => centièmes.","reward":25},
		{"domain":"Nombres et calculs","skill":"Fractions","difficulty":3,"question":"Comparer 2/3 et 3/4.","answers":["3/4 > 2/3","2/3 > 3/4","2/3 = 3/4","impossible"],"correct":0,"explanation":"3/4 > 2/3.","hint":"Mets au même dénominateur (12).","reward":25},
		{"domain":"Nombres et calculs","skill":"Fractions","difficulty":2,"question":"Simplifier 4/8.","answers":["1/2","2/4","4/8","1/4"],"correct":0,"explanation":"1/2.","hint":"Divise numérateur et dénominateur par 4.","reward":20},
		{"domain":"Nombres et calculs","skill":"Fractions","difficulty":2,"question":"Quel nombre est représenté par 5/10 ?","answers":["0,5","0,05","5","50"],"correct":0,"explanation":"0,5.","hint":"5/10 = 5 dixièmes.","reward":20},
		{"domain":"Nombres et calculs","skill":"Fractions","difficulty":2,"question":"1 - 1/3 = ?","answers":["2/3","1/3","3/3","0"],"correct":0,"explanation":"2/3.","hint":"1 = 3/3.","reward":20},
		{"domain":"Nombres et calculs","skill":"Fractions","difficulty":3,"question":"Quelle fraction est équivalente à 2/5 ?","answers":["4/10","3/5","2/10","5/2"],"correct":0,"explanation":"4/10.","hint":"Multiplie numérateur et dénominateur par 2.","reward":25},
		# Opérations
		{"domain":"Nombres et calculs","skill":"Opérations","difficulty":1,"question":"245 + 378 = ?","answers":["623","613","633","523"],"correct":0,"explanation":"623.","hint":"Additionne unités, dizaines, centaines.","reward":15},
		{"domain":"Nombres et calculs","skill":"Opérations","difficulty":2,"question":"1000 - 247 = ?","answers":["753","763","853","743"],"correct":0,"explanation":"753.","hint":"Soustrais par étapes.","reward":20},
		{"domain":"Nombres et calculs","skill":"Opérations","difficulty":2,"question":"24 × 15 = ?","answers":["360","350","370","340"],"correct":0,"explanation":"360.","hint":"24×10=240, 24×5=120.","reward":20},
		{"domain":"Nombres et calculs","skill":"Opérations","difficulty":2,"question":"144 ÷ 12 = ?","answers":["12","14","11","13"],"correct":0,"explanation":"12.","hint":"12×12=144.","reward":20},
		{"domain":"Nombres et calculs","skill":"Opérations","difficulty":2,"question":"345 × 20 = ?","answers":["6900","690","3450","6000"],"correct":0,"explanation":"6900.","hint":"×20 = ×2 puis ×10.","reward":20},
		{"domain":"Nombres et calculs","skill":"Opérations","difficulty":3,"question":"1500 ÷ 25 = ?","answers":["60","50","75","25"],"correct":0,"explanation":"60.","hint":"25×60=1500.","reward":25},
		{"domain":"Nombres et calculs","skill":"Opérations","difficulty":3,"question":"(12 + 8) × 3 = ?","answers":["60","30","24","36"],"correct":0,"explanation":"60.","hint":"D'abord la parenthèse.","reward":25},
		{"domain":"Nombres et calculs","skill":"Opérations","difficulty":1,"question":"45 × 100 = ?","answers":["4500","450","45","4050"],"correct":0,"explanation":"4500.","hint":"Ajoute 2 zéros.","reward":15},
		{"domain":"Nombres et calculs","skill":"Opérations","difficulty":3,"question":"567 - 289 = ?","answers":["278","288","268","298"],"correct":0,"explanation":"278.","hint":"Emprunte.","reward":25},
		{"domain":"Nombres et calculs","skill":"Opérations","difficulty":3,"question":"24 × 12 = ?","answers":["288","264","298","278"],"correct":0,"explanation":"288.","hint":"24×10=240, 24×2=48.","reward":25},
		# Géométrie
		{"domain":"Géométrie","skill":"Polygones","difficulty":1,"question":"Combien de côtés a un triangle ?","answers":["3","4","5","6"],"correct":0,"explanation":"3.","hint":"Tri = 3.","reward":15},
		{"domain":"Géométrie","skill":"Polygones","difficulty":1,"question":"Un carré a combien d'angles droits ?","answers":["4","2","3","1"],"correct":0,"explanation":"4.","hint":"Tous les angles du carré sont droits.","reward":15},
		{"domain":"Géométrie","skill":"Droites et segments","difficulty":2,"question":"Qu'est-ce qu'un segment ?","answers":["Une portion de droite limitée par 2 points","Une droite infinie","Une demi-droite","Un point"],"correct":0,"explanation":"Une portion de droite limitée par 2 points.","hint":"Limité par 2 points.","reward":20},
		{"domain":"Géométrie","skill":"Droites et segments","difficulty":2,"question":"Deux droites parallèles se :","answers":["ne rencontrent jamais","se croisent","sont perpendiculaires","se confondent"],"correct":0,"explanation":"ne rencontrent jamais.","hint":"Parallèle = même direction, jamais de rencontre.","reward":20},
		{"domain":"Géométrie","skill":"Angles","difficulty":1,"question":"Un angle droit mesure :","answers":["90°","180°","45°","360°"],"correct":0,"explanation":"90°.","hint":"Angle en L.","reward":15},
		{"domain":"Géométrie","skill":"Périmètres et aires","difficulty":2,"question":"Le périmètre d'un carré de côté 5 cm ?","answers":["20 cm","25 cm","10 cm","15 cm"],"correct":0,"explanation":"20 cm.","hint":"4×5=20.","reward":20},
		{"domain":"Géométrie","skill":"Symétrie","difficulty":2,"question":"Une figure symétrique par rapport à un axe :","answers":["se superpose à son image","est identique","est un carré","est un cercle"],"correct":0,"explanation":"se superpose à son image.","hint":"Miroir.","reward":20},
		{"domain":"Géométrie","skill":"Polygones","difficulty":3,"question":"Combien de diagonales a un quadrilatère ?","answers":["2","1","3","4"],"correct":0,"explanation":"2.","hint":"Relie les sommets non adjacents.","reward":25},
		{"domain":"Géométrie","skill":"Polygones","difficulty":2,"question":"Un triangle isocèle a :","answers":["2 côtés égaux","3 côtés égaux","aucun côté égal","1 angle droit"],"correct":0,"explanation":"2 côtés égaux.","hint":"Iso = égal.","reward":20},
		{"domain":"Géométrie","skill":"Périmètres et aires","difficulty":2,"question":"L'aire d'un rectangle 4 cm × 3 cm ?","answers":["12 cm²","7 cm","12 cm","14 cm²"],"correct":0,"explanation":"12 cm².","hint":"longueur × largeur.","reward":20},
		{"domain":"Géométrie","skill":"Cercle","difficulty":2,"question":"Un cercle est défini par :","answers":["son centre et son rayon","3 points","2 points","4 points"],"correct":0,"explanation":"centre et rayon.","hint":"Centre + rayon.","reward":20},
		{"domain":"Géométrie","skill":"Angles","difficulty":1,"question":"Deux droites perpendiculaires forment un angle de :","answers":["90°","180°","0°","360°"],"correct":0,"explanation":"90°.","hint":"Angle droit.","reward":15},
		# Grandeurs et mesures
		{"domain":"Grandeurs et mesures","skill":"Conversions","difficulty":1,"question":"1 km = ? m","answers":["1000","100","10","10000"],"correct":0,"explanation":"1000.","hint":"kilo = 1000.","reward":15},
		{"domain":"Grandeurs et mesures","skill":"Conversions","difficulty":1,"question":"1 kg = ? g","answers":["1000","100","10","500"],"correct":0,"explanation":"1000.","hint":"kilo = 1000.","reward":15},
		{"domain":"Grandeurs et mesures","skill":"Conversions","difficulty":2,"question":"1 L = ? cL","answers":["100","10","1000","50"],"correct":0,"explanation":"100.","hint":"centi = 1/100, donc 100 cL.","reward":20},
		{"domain":"Grandeurs et mesures","skill":"Conversions","difficulty":1,"question":"1 h = ? min","answers":["60","100","30","24"],"correct":0,"explanation":"60.","hint":"Une heure = 60 minutes.","reward":15},
		{"domain":"Grandeurs et mesures","skill":"Conversions","difficulty":2,"question":"Convertir 2,5 kg en grammes.","answers":["2500 g","250 g","25 g","25000 g"],"correct":0,"explanation":"2500 g.","hint":"×1000.","reward":20},
		{"domain":"Grandeurs et mesures","skill":"Durées","difficulty":3,"question":"Quelle est la durée entre 9h15 et 11h45 ?","answers":["2h30","2h15","1h30","3h"],"correct":0,"explanation":"2h30.","hint":"De 9h15 à 11h15 = 2h, puis 30 min.","reward":25},
		{"domain":"Grandeurs et mesures","skill":"Périmètres et aires","difficulty":2,"question":"Aire d'un carré de côté 6 cm ?","answers":["36 cm²","24 cm","12 cm²","36 cm"],"correct":0,"explanation":"36 cm².","hint":"6×6.","reward":20},
		{"domain":"Grandeurs et mesures","skill":"Périmètres et aires","difficulty":2,"question":"Périmètre d'un rectangle 5 cm × 3 cm ?","answers":["16 cm","15 cm","8 cm","30 cm"],"correct":0,"explanation":"16 cm.","hint":"2×(5+3).","reward":20},
		{"domain":"Grandeurs et mesures","skill":"Volumes","difficulty":3,"question":"Volume d'un cube de côté 2 cm ?","answers":["8 cm³","6 cm²","4 cm³","12 cm³"],"correct":0,"explanation":"8 cm³.","hint":"2³.","reward":25},
		{"domain":"Grandeurs et mesures","skill":"Conversions","difficulty":1,"question":"1 m = ? cm","answers":["100","10","1000","50"],"correct":0,"explanation":"100.","hint":"mètre = 100 cm.","reward":15},
		{"domain":"Grandeurs et mesures","skill":"Durées","difficulty":2,"question":"Combien de secondes dans 3 minutes ?","answers":["180","60","120","300"],"correct":0,"explanation":"180.","hint":"3×60.","reward":20},
		{"domain":"Grandeurs et mesures","skill":"Masses et capacités","difficulty":2,"question":"Masse de 3 paquets de 250 g ?","answers":["750 g","500 g","1000 g","250 g"],"correct":0,"explanation":"750 g.","hint":"3×250.","reward":20},
		# Organisation et gestion de données
		{"domain":"Organisation et gestion de données","skill":"Tableaux","difficulty":1,"question":"Dans un tableau, une ligne horizontale s'appelle :","answers":["une ligne","une colonne","une cellule","un titre"],"correct":0,"explanation":"une ligne.","hint":"Horizontale = ligne.","reward":15},
		{"domain":"Organisation et gestion de données","skill":"Moyenne et médiane","difficulty":3,"question":"La moyenne de 4, 6, 8, 10 est :","answers":["7","6","8","28"],"correct":0,"explanation":"7.","hint":"Somme/4.","reward":25},
		{"domain":"Organisation et gestion de données","skill":"Moyenne et médiane","difficulty":4,"question":"Quelle est la médiane de 2,5,7,9,12 ?","answers":["7","5","9","28"],"correct":0,"explanation":"7.","hint":"Valeur centrale.","reward":30},
		{"domain":"Organisation et gestion de données","skill":"Probabilités","difficulty":2,"question":"Probabilité d'obtenir pile avec une pièce équilibrée ?","answers":["1/2","1","0","1/4"],"correct":0,"explanation":"1/2.","hint":"2 issues équiprobables.","reward":20},
		{"domain":"Organisation et gestion de données","skill":"Probabilités","difficulty":2,"question":"Dans un dé à 6 faces, proba d'obtenir un 6 ?","answers":["1/6","1/3","1/2","1"],"correct":0,"explanation":"1/6.","hint":"1 issue sur 6.","reward":20},
		{"domain":"Organisation et gestion de données","skill":"Tableaux","difficulty":2,"question":"L'effectif total d'une série est :","answers":["le nombre de valeurs","la plus grande valeur","la moyenne","la somme"],"correct":0,"explanation":"le nombre de valeurs.","hint":"Effectif = nombre.","reward":20},
		{"domain":"Organisation et gestion de données","skill":"Graphiques","difficulty":1,"question":"Un diagramme en barres sert à :","answers":["comparer des quantités","calculer","mesurer","dessiner"],"correct":0,"explanation":"comparer des quantités.","hint":"Visualiser.","reward":15},
		{"domain":"Organisation et gestion de données","skill":"Probabilités","difficulty":3,"question":"La somme des probabilités de tous les résultats possibles est :","answers":["1","0","100","infini"],"correct":0,"explanation":"1.","hint":"Certitude.","reward":25},
	]
	for r in raw:
		var q = r.duplicate()
		q["id"] = "q_" + str(randi())
		ALL.append(q)

func gen_operation(difficulty: int) -> Dictionary:
	var ops = ["+","-","×","÷"]
	var a:int; var b:int; var op:String; var res:int
	if difficulty <= 1:
		op = "+" if randi()%2==0 else "-"
		a = randi_range(10,99); b = randi_range(10,99)
	elif difficulty == 2:
		var r = randi()%3
		if r == 2:
			op = "×"; a = randi_range(2,12); b = randi_range(2,12)
		else:
			op = "+" if randi()%2==0 else "-"; a = randi_range(10,99); b = randi_range(10,99)
	elif difficulty == 3:
		var r = randi()%3
		op = ops[r]
		a = randi_range(50,500); b = randi_range(10,99)
		if op == "×": a = randi_range(5,20); b = randi_range(5,20)
		if op == "÷": b = randi_range(2,12); a = b * randi_range(2,12)
	else:
		var r = randi()%4
		op = ops[r]
		a = randi_range(100,999); b = randi_range(10,99)
		if op == "×": a = randi_range(10,50); b = randi_range(10,50)
		if op == "÷": b = randi_range(3,15); a = b * randi_range(5,20)
	if op == "+": res = a + b
	elif op == "-":
		if b > a: var t = a; a = b; b = t
		res = a - b
	elif op == "×": res = a * b
	else: res = int(a / b)
	var set = [res]
	while set.size() < 4:
		var v = res + randi_range(-20,20)
		if v != res and not set.has(v): set.append(v)
	var choices = set.duplicate()
	choices.shuffle()
	var idx = choices.find(res)
	return {"id":"gen_"+str(randi()),"domain":"Nombres et calculs","skill":"Opérations","difficulty":difficulty,"question":str(a)+" "+op+" "+str(b)+" = ?","answers":choices.map(func(x): return str(x)),"correct":idx,"explanation":str(a)+" "+op+" "+str(b)+" = "+str(res),"hint":"Pense à la table ou décompose.","reward":10+difficulty*5}

# appelé au chargement
func _ready():
	_init_db()
	# s'assurer que ALL est rempli même si _ready appelé
	if ALL.is_empty(): _init_db()
