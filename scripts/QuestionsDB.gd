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
		{"domain":"Nombres et calculs","skill":"Grands nombres","difficulty":3,"question":"Quelle décomposition donne 6 304 218 ?","answers":["6 millions, 304 milliers, 218 unités","6 millions, 340 milliers, 218 unités","6 millions, 304 milliers, 281 unités","6 millions, 34 milliers, 218 unités"],"correct":0,"explanation":"6 000 000 + 304 000 + 218 = 6 304 218.","hint":"Lis les groupes de trois chiffres de gauche à droite.","reward":25},
		{"domain":"Nombres et calculs","skill":"Grands nombres","difficulty":1,"question":"Combien de zéros dans un million ?","answers":["6","5","7","9"],"correct":0,"explanation":"6 zéros.","hint":"1 000 000.","reward":15},
		{"domain":"Nombres et calculs","skill":"Grands nombres","difficulty":2,"question":"Écrire en chiffres : quatre-vingt-dix mille six cent douze.","answers":["90 612","80 912","90 600 12","980 612"],"correct":0,"explanation":"90 612.","hint":"quatre-vingt-dix = 90.","reward":20},
		{"domain":"Nombres et calculs","skill":"Grands nombres","difficulty":3,"question":"Quel est le rang du chiffre 3 dans 2 345 678 ?","answers":["centaines de mille","dizaines de mille","millions","milliers"],"correct":0,"explanation":"centaines de mille.","hint":"Positions : ... millions, centaines de mille...","reward":25},
		# Multiples et diviseurs
		{"domain":"Nombres et calculs","skill":"Multiples et diviseurs","difficulty":3,"question":"Quel est le plus petit multiple commun de 4 et 6 ?","answers":["12","24","6","4"],"correct":0,"explanation":"PPCM(4,6)=12.","hint":"Liste les multiples.","reward":25},
		{"domain":"Nombres et calculs","skill":"Multiples et diviseurs","difficulty":2,"question":"36 est-il divisible par 9 ?","answers":["Oui","Non"],"correct":0,"explanation":"36/9=4.","hint":"9×4=36.","reward":20},
		{"domain":"Nombres et calculs","skill":"Multiples et diviseurs","difficulty":3,"question":"Quels sont les diviseurs de 12 ?","answers":["1,2,3,4,6,12","1,2,4,6,12","1,3,4,12","2,3,4,6"],"correct":0,"explanation":"1,2,3,4,6,12.","hint":"Un diviseur divise sans reste.","reward":25},
		{"domain":"Nombres et calculs","skill":"Multiples et diviseurs","difficulty":2,"question":"Lequel est un multiple de 7 ?","answers":["49","50","48","57"],"correct":0,"explanation":"49 est dans la table de 7 : 7 × 7 = 49.","hint":"Compte de 7 en 7.","reward":20},
		{"domain":"Nombres et calculs","skill":"Multiples et diviseurs","difficulty":4,"question":"PGCD de 18 et 24 ?","answers":["6","3","12","2"],"correct":0,"explanation":"PGCD(18,24)=6.","hint":"Diviseurs communs.","reward":30},
		{"domain":"Nombres et calculs","skill":"Multiples et diviseurs","difficulty":2,"question":"Un nombre divisible par 2 et par 5 est divisible par ?","answers":["10","20","7","3"],"correct":0,"explanation":"10.","hint":"2×5=10.","reward":20},
		# Fractions
		{"domain":"Nombres et calculs","skill":"Fractions","difficulty":1,"question":"Quelle fraction représente la moitié ?","answers":["1/2","1/3","2/1","1/4"],"correct":0,"explanation":"1/2.","hint":"Moitié = 1 sur 2.","reward":15},
		{"domain":"Nombres et calculs","skill":"Fractions","difficulty":2,"question":"1/4 + 1/4 = ?","answers":["2/4","1/4","1/8","2/8"],"correct":0,"explanation":"Un quart plus un quart donne deux quarts. On additionne les numérateurs et on garde le dénominateur 4.","hint":"Imagine deux parts d’une tarte coupée en quatre.","reward":20},
		{"domain":"Nombres et calculs","skill":"Fractions","difficulty":3,"question":"Quelle est la fraction décimale de 0,75 ?","answers":["75/100","7/10","3/4","75/10"],"correct":0,"explanation":"75/100.","hint":"2 décimales => centièmes.","reward":25},
		{"domain":"Nombres et calculs","skill":"Fractions","difficulty":3,"question":"Comparer 2/3 et 3/4.","answers":["3/4 > 2/3","2/3 > 3/4","2/3 = 3/4","impossible"],"correct":0,"explanation":"3/4 > 2/3.","hint":"Mets au même dénominateur (12).","reward":25},
		{"domain":"Nombres et calculs","skill":"Fractions","difficulty":2,"question":"Quelle est la forme la plus simple de 4/8 ?","answers":["1/2","2/4","4/8","1/4"],"correct":0,"explanation":"Divise 4 et 8 par 4 : tu obtiens 1/2. Les nombres 1 et 2 ne peuvent plus être divisés par un même nombre plus grand que 1.","hint":"Cherche un même nombre qui divise 4 et 8.","reward":20},
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
		{"domain":"Organisation et gestion de données","skill":"Tableaux","difficulty":2,"question":"Le registre de l’île compte 12 visites lundi, 17 mardi et 9 mercredi. Quel est le total des visites ?","answers":["38","29","26","39"],"correct":0,"explanation":"On additionne les trois jours : 12 + 17 = 29, puis 29 + 9 = 38.","hint":"Additionne les visites des trois jours.","reward":20},
		{"domain":"Organisation et gestion de données","skill":"Graphiques","difficulty":2,"question":"Sur un diagramme, une graduation représente 5 arbres. La barre du jardin atteint la 4e graduation au-dessus de zéro. Combien d’arbres y a-t-il ?","answers":["20","4","9","25"],"correct":0,"explanation":"Il y a quatre groupes de cinq arbres : 4 × 5 = 20.","hint":"Compte de cinq en cinq depuis zéro.","reward":20},
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

# ---------------------------------------------------------------------------
# Vidéos ciblées (jaicompris.com) et explicatif vocal de secours
# ---------------------------------------------------------------------------
const SITE := "https://jaicompris.com"
const V_CHIFFRES := SITE + "/lycee/math/ensemble/entier/nombres_entiers_chiffre_nombre.php"
const V_COMPARER := SITE + "/lycee/math/ensemble/entier/nombres_entiers.php"
const V_MULTIPLES := SITE + "/lycee/math/arithmetique/multiple_diviseur.php"
const V_DIVISIBILITE := SITE + "/lycee/math/arithmetique/critere_divisibilite.php"
const V_DIVISION := SITE + "/lycee/math/arithmetique/division_euclidienne_sixieme.php"
const V_DIVISION_DEC := SITE + "/lycee/math/arithmetique/division_decimale.php"
const V_FRACTIONS := SITE + "/lycee/math/calcul/fraction/fraction_intro_sixieme.php"
const V_FRACTIONS_ADD := SITE + "/lycee/math/calcul/fraction/fraction_addition_sixieme.php"
const V_MOITIE_QUART := SITE + "/lycee/math/calcul/multiplier/moitie_quart.php"
const V_DECIMAUX := SITE + "/lycee/math/ensemble/decimaux/nombres_decimaux.php"
const V_ADDITION := SITE + "/lycee/math/calcul/calcul-mental.php"
const V_SOUSTRACTION := SITE + "/lycee/math/calcul/addition/soustraction_posee_entier.php"
const V_MULTIPLICATION := SITE + "/lycee/math/calcul/multiplier/multiplication_entier.php"
const V_PRIORITES := SITE + "/lycee/math/ensemble/entier/priorite_operatoire.php"
const V_TRIANGLE := SITE + "/lycee/math/figure/triangle/triangle_vocabulaire.php"
const V_QUADRILATERE := SITE + "/lycee/math/figure/quadrilatere/quadrilatere_vocabulaire.php"
const V_DROITE := SITE + "/lycee/math/droite/droite_sixieme.php"
const V_PARALLELES := SITE + "/lycee/math/droite/droite_parallele_6e.php"
const V_PERPENDICULAIRES := SITE + "/lycee/math/droite/droite_perpendiculaire_6e.php"
const V_SEGMENT := SITE + "/lycee/math/droite/segment_milieu.php"
const V_ANGLE := SITE + "/lycee/math/angle/angle_sixieme/angle_sixieme.php"
const V_ANGLES_TYPES := SITE + "/lycee/math/angle/angle_sixieme/angle_aigu_obtu_droit.php"
const V_PERIMETRE := SITE + "/lycee/math/grandeur/longueur/perimetre_rectangle_cercle.php"
const V_AIRE := SITE + "/lycee/math/grandeur/aire/aire_rectangle_disque.php"
const V_SYMETRIE := SITE + "/lycee/math/transformation/symetrie_axiale/symetrie_axiale_sixieme.php"
const V_AXE := SITE + "/lycee/math/transformation/symetrie_axiale/axe_symetrie_figure.php"
const V_CERCLE := SITE + "/lycee/math/figure/cercle/cercle_vocabulaire.php"
const V_LONGUEUR := SITE + "/lycee/math/grandeur/longueur/longueur_sixieme.php"
const V_MASSE := SITE + "/lycee/math/grandeur/masse/masse_sixieme.php"
const V_DUREE := SITE + "/lycee/math/grandeur/duree/duree.php"
const V_VOLUME := SITE + "/lycee/math/grandeur/volume/volume_sixieme_pave_droit.php"
const V_TABLEAU := SITE + "/lycee/math/statistique/tableau/donnees_tableau_sixieme.php"
const V_MOYENNE := SITE + "/lycee/math/statistique/moyenne/moyenne_cinquieme.php"
const V_MEDIANE := SITE + "/lycee/math/statistique/mediane/mediane_quatrieme.php"
const V_PROBA := SITE + "/lycee/math/probabilite/probabilite_cinquieme/probabilite_cinquieme.php"
const V_BARRES := SITE + "/lycee/math/statistique/histogramme/diagramme_baton_sixieme.php"
const V_GRAPHIQUE := SITE + "/lycee/math/statistique/graphique/lire_graphique_sixieme.php"

const VIDEO_BY_SKILL := {
	"Grands nombres": V_CHIFFRES,
	"Multiples et diviseurs": V_MULTIPLES,
	"Fractions": V_FRACTIONS,
	"Opérations": V_PRIORITES,
	"Polygones": V_TRIANGLE,
	"Droites et segments": V_DROITE,
	"Angles": V_ANGLE,
	"Périmètres et aires": V_PERIMETRE,
	"Symétrie": V_SYMETRIE,
	"Cercle": V_CERCLE,
	"Conversions": V_LONGUEUR,
	"Durées": V_DUREE,
	"Volumes": V_VOLUME,
	"Masses et capacités": V_MASSE,
	"Tableaux": V_TABLEAU,
	"Moyenne et médiane": V_MOYENNE,
	"Probabilités": V_PROBA,
	"Graphiques": V_BARRES,
}

const LESSON_BY_SKILL := {
	"Grands nombres": "Lis le nombre par groupes de trois chiffres : millions, milliers, unités. Chaque groupe se lit comme un nombre de trois chiffres, puis on ajoute le nom du groupe.",
	"Multiples et diviseurs": "Un multiple est le résultat d'une multiplication. Un diviseur divise sans reste. Pour le PPCM, liste les multiples ; pour le PGCD, liste les diviseurs communs.",
	"Fractions": "Une fraction représente une ou plusieurs parts d'un tout partagé en parts égales. Le dénominateur indique le nombre de parts, le numérateur le nombre de parts choisies.",
	"Opérations": "Aligne les unités, les dizaines et les centaines pour additionner ou soustraire. Décompose les nombres pour multiplier, et cherche le nombre de fois que le diviseur est contenu pour diviser.",
	"Polygones": "Un polygone est une figure fermée formée de segments. Le triangle a trois côtés, le quadrilatère quatre. Un carré a quatre côtés égaux et quatre angles droits.",
	"Droites et segments": "Une droite est infinie, une demi-droite a une origine et un segment a deux extrémités. Des droites parallèles ne se croisent jamais ; des droites perpendiculaires forment un angle droit.",
	"Angles": "Un angle se mesure en degrés. Un angle droit vaut quatre-vingt-dix degrés, un angle plat cent quatre-vingts degrés et un tour complet trois cent soixante degrés.",
	"Périmètres et aires": "Le périmètre est la longueur du contour. Pour un carré, multiplie le côté par quatre. L'aire d'un rectangle est la longueur multipliée par la largeur, et s'exprime en centimètres carrés.",
	"Symétrie": "Une figure est symétrique par rapport à un axe si, pliée le long de cet axe, ses deux parties se superposent exactement. Chaque point et son image sont à égale distance de l'axe.",
	"Cercle": "Un cercle est défini par son centre et son rayon. Tous les points du cercle sont à la même distance du centre. Le diamètre passe par le centre et vaut deux rayons.",
	"Conversions": "Pour convertir, multiplie ou divise par la valeur de l'unité. Kilo signifie mille, centi signifie centième et milli signifie millième.",
	"Durées": "Une heure vaut soixante minutes et une minute vaut soixante secondes. Pour calculer une durée, avance heure par heure, puis minutes par minutes.",
	"Volumes": "Le volume d'un pavé droit est la longueur multipliée par la largeur, puis par la hauteur. Pour un cube, on multiplie le côté trois fois, et on exprime le résultat en centimètres cubes.",
	"Masses et capacités": "Un kilogramme vaut mille grammes. Un litre vaut cent centilitres et mille millilitres.",
	"Tableaux": "Dans un tableau, chaque case appartient à une ligne et à une colonne. Pour retrouver une information, lis d'abord l'en-tête de la ligne, puis celui de la colonne.",
	"Moyenne et médiane": "La moyenne est la somme des valeurs divisée par le nombre de valeurs. La médiane est la valeur centrale lorsque les valeurs sont classées par ordre croissant.",
	"Probabilités": "La probabilité est le nombre d'issues favorables divisé par le nombre total d'issues équiprobables. La somme des probabilités de toutes les issues possibles vaut un.",
	"Graphiques": "Un diagramme en barres sert à comparer des quantités. Pour lire une barre, repère la graduation atteinte, puis multiplie par la valeur d'une graduation.",
}

# Choix de la vidéo jaicompris.com la plus proche de la notion travaillée.
func video_url(q: Dictionary) -> String:
	var skill := str(q.get("skill", ""))
	var text := str(q.get("question", "")).to_lower()
	if skill == "Grands nombres":
		return V_COMPARER if ("plus grand" in text or "compare" in text) else V_CHIFFRES
	if skill == "Multiples et diviseurs":
		if "divisible" in text and not "pgcd" in text and not "ppcm" in text:
			return V_DIVISIBILITE
		return V_MULTIPLES
	if skill == "Fractions":
		if "+" in text or "addition" in text:
			return V_FRACTIONS_ADD
		if "0," in text or "décimale" in text or "dixième" in text:
			return V_DECIMAUX
		if "moitié" in text or "1/2" in text or "quart" in text:
			return V_MOITIE_QUART
		return V_FRACTIONS
	if skill == "Opérations":
		if "÷" in text or "divis" in text:
			return V_DIVISION_DEC if "décimal" in text else V_DIVISION
		if "×" in text or "multipli" in text:
			return V_MULTIPLICATION
		if "-" in text or "soustrai" in text or "emprunte" in text:
			return V_SOUSTRACTION
		if "(" in text:
			return V_PRIORITES
		return V_ADDITION
	if skill == "Polygones":
		return V_QUADRILATERE if ("carré" in text or "quadrilatère" in text or "diagonale" in text) else V_TRIANGLE
	if skill == "Droites et segments":
		if "parallèle" in text:
			return V_PARALLELES
		if "perpendiculaire" in text:
			return V_PERPENDICULAIRES
		if "segment" in text:
			return V_SEGMENT
		return V_DROITE
	if skill == "Angles":
		return V_ANGLES_TYPES if ("droit" in text or "90" in text) else V_ANGLE
	if skill == "Périmètres et aires":
		return V_AIRE if "aire" in text else V_PERIMETRE
	if skill == "Symétrie":
		return V_AXE if "axe" in text else V_SYMETRIE
	if skill == "Conversions":
		if "kg" in text or " gramme" in text or "g ?" in text:
			return V_MASSE
		if "l" in text or "cl" in text or "ml" in text:
			return V_VOLUME
		return V_LONGUEUR
	if skill == "Masses et capacités":
		return V_MASSE
	if skill == "Durées":
		return V_DUREE
	if skill == "Volumes":
		return V_VOLUME
	if skill == "Cercle":
		return V_CERCLE
	if skill == "Tableaux":
		return V_TABLEAU
	if skill == "Moyenne et médiane":
		return V_MEDIANE if "médiane" in text else V_MOYENNE
	if skill == "Probabilités":
		return V_PROBA
	if skill == "Graphiques":
		return V_BARRES if ("barres" in text or "diagramme" in text) else V_GRAPHIQUE
	return str(VIDEO_BY_SKILL.get(skill, ""))

# Ouvre la vidéo dans un nouvel onglet (web) ou dans le navigateur (desktop).
func open_video(q: Dictionary) -> bool:
	var url := video_url(q)
	if url.is_empty():
		return false
	if OS.has_feature("web"):
		var opened: String = JavaScriptBridge.eval(
			"(function(){var w=window.open(%s, '_blank', 'noopener'); return w ? 'ok' : 'blocked';})()" % JSON.stringify(url))
		return opened == "ok"
	OS.shell_open(url)
	return true

# Explication courte, lue à voix haute si aucune vidéo n'est disponible.
func narrated_lesson(q: Dictionary) -> String:
	var parts := PackedStringArray()
	var method := str(LESSON_BY_SKILL.get(str(q.get("skill", "")), ""))
	if not method.is_empty():
		parts.append(method)
	var explanation := str(q.get("explanation", ""))
	if not explanation.is_empty():
		parts.append(explanation)
	var hint := str(q.get("hint", ""))
	if not hint.is_empty():
		parts.append(hint)
	return " ".join(parts)

# appelé au chargement
func _ready():
	_init_db()
	# s'assurer que ALL est rempli même si _ready appelé
	if ALL.is_empty(): _init_db()
