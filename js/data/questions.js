// Banque de questions MathArthur - Programme CM2 complet
// Chaque question: { id, domain, skill, difficulty(1-5), type, question, visual, answers:[], correct, explanation, videoUrl, hint }

const MATHARTHUR_QUESTIONS = [];

// Utilitaires
function rnd(min, max){ return Math.floor(Math.random()*(max-min+1))+min; }
function shuffle(arr){ const a=[...arr]; for(let i=a.length-1;i>0;i--){const j=Math.floor(Math.random()*(i+1));[a[i],a[j]]=[a[j],a[i]];} return a; }

// ===== DOMAINE 1 : NOMBRES ET CALCULS =====

// 1.1 Grands nombres - lecture/écriture
const grandsNombres = [
  {q:"Comment écrit-on 'trois millions quatre cent vingt mille quinze' ?", a:["3 420 015","3 042 015","3 402 015","3 420 150"], c:0, d:2},
  {q:"Quel est le chiffre des dizaines de mille dans 4 587 231 ?", a:["8","5","7","2"], c:0, d:2},
  {q:"Combien vaut 7 millions + 45 mille + 3 ?", a:["7 045 003","7 450 003","7 004 503","7 405 003"], c:0, d:2},
  {q:"Quel nombre est le plus grand ?", a:["4 500 000","4 050 000","4 005 000","4 000 500"], c:0, d:1},
  {q:"Décomposer 6 304 218 en millions, milliers et unités", a:["6 millions, 304 milliers, 218","6 millions, 300 milliers, 4218","6 millions, 304 mille, 218","6 M, 304 k, 218"], c:2, d:3},
  {q:"Combien de zéros dans un million ?", a:["6","5","7","9"], c:0, d:1},
  {q:"Écrire en chiffres : quatre-vingt-dix mille six cent douze", a:["90 612","80 912","90 600 12","980 612"], c:0, d:2},
  {q:"Quel est le rang du chiffre 3 dans 2 345 678 ?", a:["centaines de mille","dizaines de mille","millions","milliers"], c:0, d:3},
];

// 1.2 Multiples et diviseurs
const multiplesDiviseurs = [
  {q:"Quel est le plus petit multiple commun de 4 et 6 ?", a:["12","24","6","4"], c:0, d:3},
  {q:"36 est-il divisible par 9 ?", a:["Oui","Non"], c:0, d:2},
  {q:"Quels sont les diviseurs de 12 ?", a:["1,2,3,4,6,12","1,2,4,6,12","1,3,4,12","2,3,4,6"], c:0, d:3},
  {q:"Lequel est un multiple de 7 ?", a:["49","42? non","50","48"], c:0, d:2},
  {q:"PGCD de 18 et 24 ?", a:["6","3","12","2"], c:0, d:4},
  {q:"Un nombre divisible par 2 et par 5 est divisible par ?", a:["10","20","7","3"], c:0, d:2},
  {q:"Les multiples de 3 jusqu'à 30 sont :", a:["3,6,9,12,15,18,21,24,27,30","3,6,9,12,15,18,21,24,27","3,9,15,21,27","3,6,9,12,15,18,21,24,27,30,33"], c:0, d:2},
];

// 1.3 Fractions
const fractions = [
  {q:"Quelle fraction représente la moitié ?", a:["1/2","1/3","2/1","1/4"], c:0, d:1},
  {q:"1/4 + 1/4 = ?", a:["1/2","2/4","1/8","2/8"], c:0, d:2},
  {q:"Quelle est la fraction décimale de 0,75 ?", a:["75/100","7/10","3/4","75/10"], c:0, d:3},
  {q:"Comparer 2/3 et 3/4", a:["3/4 > 2/3","2/3 > 3/4","2/3 = 3/4","impossible"], c:0, d:3},
  {q:"Simplifier 4/8", a:["1/2","2/4","4/8","1/4"], c:0, d:2},
  {q:"Quel nombre est représenté par 5/10 ?", a:["0,5","0,05","5","50"], c:0, d:2},
  {q:"1 - 1/3 = ?", a:["2/3","1/3","3/3","0"], c:0, d:2},
  {q:"Quelle fraction est équivalente à 2/5 ?", a:["4/10","3/5","2/10","5/2"], c:0, d:3},
];

// 1.4 Opérations
const operations = [
  {q:"245 + 378 = ?", a:["623","613","633","523"], c:0, d:1},
  {q:"1000 - 247 = ?", a:["753","763","853","743"], c:0, d:2},
  {q:"24 × 15 = ?", a:["360","350","370","340"], c:0, d:2},
  {q:"144 ÷ 12 = ?", a:["12","14","11","13"], c:0, d:2},
  {q:"345 × 20 = ?", a:["6900","690","3450","6000"], c:0, d:2},
  {q:"1500 ÷ 25 = ?", a:["60","50","75","25"], c:0, d:3},
  {q:"(12 + 8) × 3 = ?", a:["60","30","24","36"], c:0, d:3},
  {q:"Quel est le résultat de 45 × 100 ?", a:["4500","450","45","4050"], c:0, d:1},
  {q:"567 - 289 = ?", a:["278","288","268","298"], c:0, d:3},
  {q:"24 × 12 = ?", a:["288","264","298","278"], c:0, d:3},
];

// Générateur d'opérations adaptatives
function genOperation(diff){
  const ops = ['+','-','×','÷'];
  let a,b,op,res,choices;
  if(diff<=1){ op=rnd(0,1)===0?'+':'-'; a=rnd(10,99); b=rnd(10,99); }
  else if(diff===2){ op=rnd(0,2)===2?'×':(rnd(0,1)===0?'+':'-'); a=rnd(10,99); b=rnd(10,99); if(op==='×'){a=rnd(2,12);b=rnd(2,12);} }
  else if(diff===3){ op=ops[rnd(0,2)]; a=rnd(50,500); b=rnd(10,99); if(op==='×'){a=rnd(5,20);b=rnd(5,20);} if(op==='÷'){b=rnd(2,12);a=b*rnd(2,12);} }
  else { op=ops[rnd(0,3)]; a=rnd(100,999); b=rnd(10,99); if(op==='×'){a=rnd(10,50);b=rnd(10,50);} if(op==='÷'){b=rnd(3,15);a=b*rnd(5,20);} }
  if(op==='+') res=a+b;
  else if(op==='-'){ if(b>a){[a,b]=[b,a];} res=a-b; }
  else if(op==='×') res=a*b;
  else res=a/b;
  // choices
  const set=new Set([res]);
  while(set.size<4){ set.add(res + rnd(-20,20)||res+1); }
  choices=shuffle([...set]);
  return {
    domain:"Nombres et calculs", skill:"Opérations", difficulty:diff,
    question:`${a} ${op} ${b} = ?`,
    answers:choices.map(String), correct:choices.indexOf(res),
    explanation:`${a} ${op} ${b} = ${res}`,
    hint:`Pense à la table ou décompose le calcul.`
  };
}

// ===== DOMAINE 2 : GÉOMÉTRIE =====
const geometrie = [
  {q:"Combien de côtés a un triangle ?", a:["3","4","5","6"], c:0, d:1},
  {q:"Un carré a combien d'angles droits ?", a:["4","2","3","1"], c:0, d:1},
  {q:"Qu'est-ce qu'un segment ?", a:["Une portion de droite limitée par 2 points","Une droite infinie","Une demi-droite","Un point"], c:0, d:2},
  {q:"Deux droites parallèles se :", a:["ne rencontrent jamais","se croisent","sont perpendiculaires","se confondent"], c:0, d:2},
  {q:"Un angle droit mesure :", a:["90°","180°","45°","360°"], c:0, d:1},
  {q:"Le périmètre d'un carré de côté 5 cm ?", a:["20 cm","25 cm","10 cm","15 cm"], c:0, d:2},
  {q:"Une figure symétrique par rapport à un axe :", a:["se superpose à son image","est identique","est un carré","est un cercle"], c:0, d:2},
  {q:"Combien de diagonales a un quadrilatère ?", a:["2","1","3","4"], c:0, d:3},
  {q:"Un triangle isocèle a :", a:["2 côtés égaux","3 côtés égaux","aucun côté égal","1 angle droit"], c:0, d:2},
  {q:"L'aire d'un rectangle 4 cm × 3 cm ?", a:["12 cm²","7 cm","12 cm","14 cm²"], c:0, d:2},
  {q:"Un cercle est défini par :", a:["son centre et son rayon","3 points","2 points","4 points"], c:0, d:2},
  {q:"Deux droites perpendiculaires forment un angle de :", a:["90°","180°","0°","360°"], c:0, d:1},
];

// ===== DOMAINE 3 : GRANDEURS ET MESURES =====
const grandeurs = [
  {q:"1 km = ? m", a:["1000","100","10","10000"], c:0, d:1},
  {q:"1 kg = ? g", a:["1000","100","10","500"], c:0, d:1},
  {q:"1 L = ? cL", a:["100","10","1000","50"], c:0, d:2},
  {q:"1 h = ? min", a:["60","100","30","24"], c:0, d:1},
  {q:"Convertir 2,5 kg en grammes", a:["2500 g","250 g","25 g","25000 g"], c:0, d:2},
  {q:"Quelle est la durée entre 9h15 et 11h45 ?", a:["2h30","2h15","1h30","3h"], c:0, d:3},
  {q:"Aire d'un carré de côté 6 cm ?", a:["36 cm²","24 cm","12 cm²","36 cm"], c:0, d:2},
  {q:"Périmètre d'un rectangle 5 cm × 3 cm ?", a:["16 cm","15 cm","8 cm","30 cm"], c:0, d:2},
  {q:"Volume d'un cube de côté 2 cm ?", a:["8 cm³","6 cm²","4 cm³","12 cm³"], c:0, d:3},
  {q:"1 m = ? cm", a:["100","10","1000","50"], c:0, d:1},
  {q:"Combien de secondes dans 3 minutes ?", a:["180","60","120","300"], c:0, d:2},
  {q:"Massse de 3 paquets de 250 g ?", a:["750 g","500 g","1000 g","250 g"], c:0, d:2},
];

// ===== DOMAINE 4 : ORGANISATION ET GESTION DE DONNÉES =====
const donnees = [
  {q:"Dans un tableau, une ligne horizontale s'appelle :", a:["une ligne","une colonne","une cellule","un titre"], c:0, d:1},
  {q:"La moyenne de 4, 6, 8, 10 est :", a:["7","6","8","28"], c:0, d:3},
  {q:"Quelle est la médiane de 2,5,7,9,12 ?", a:["7","5","9","28"], c:0, d:4},
  {q:"Probabilité d'obtenir pile avec une pièce équilibrée ?", a:["1/2","1","0","1/4"], c:0, d:2},
  {q:"Dans un dé à 6 faces, proba d'obtenir un 6 ?", a:["1/6","1/3","1/2","1"], c:0, d:2},
  {q:"L'effectif total d'une série est :", a:["le nombre de valeurs","la plus grande valeur","la moyenne","la somme"], c:0, d:2},
  {q:"Un diagramme en barres sert à :", a:["comparer des quantités","calculer","mesurer","dessiner"], c:0, d:1},
  {q:"La somme des probabilités de tous les résultats possibles est :", a:["1","0","100","infini"], c:0, d:3},
];

// Convertir en format standard avec métadonnées
function makeQ(raw, domain){
  return {
    id: 'q_'+Math.random().toString(36).slice(2,9),
    domain: domain,
    skill: raw.skill || domain,
    difficulty: raw.d,
    type: 'mcq',
    question: raw.q,
    visual: raw.visual || '',
    answers: raw.a,
    correct: raw.c,
    explanation: raw.explanation || `La bonne réponse est : ${raw.a[raw.c]}.`,
    hint: raw.hint || "Relis bien la question et élimine les réponses impossibles.",
    videoUrl: raw.videoUrl || null,
    reward: 10 + raw.d*5
  };
}

// Assembler la banque
const domainsMap = {
  "Nombres et calculs": [...grandsNombres, ...multiplesDiviseurs, ...fractions, ...operations],
  "Géométrie": geometrie,
  "Grandeurs et mesures": grandeurs,
  "Organisation et gestion de données": donnees,
};

// Skill labels
const skillLabels = {
  "Nombres et calculs": ["Grands nombres","Multiples et diviseurs","Fractions","Opérations","Calcul mental"],
  "Géométrie": ["Droites et segments","Angles","Polygones","Symétrie","Périmètres et aires"],
  "Grandeurs et mesures": ["Conversions","Durées","Aires et volumes","Masses et capacités"],
  "Organisation et gestion de données": ["Tableaux","Moyenne et médiane","Probabilités","Graphiques"],
};

Object.keys(domainsMap).forEach(dom => {
  domainsMap[dom].forEach(raw => {
    MATHARTHUR_QUESTIONS.push(makeQ(raw, dom));
  });
});

// Générateur de questions d'opérations à la volée (pour variété)
function generateOperationQuestion(difficulty){
  return makeQ({...genOperation(difficulty), skill:'Opérations'}, "Nombres et calculs");
}

// Export
window.MATHARTHUR_QUESTIONS = MATHARTHUR_QUESTIONS;
window.generateOperationQuestion = generateOperationQuestion;
window.MATHARTHUR_DOMAINS = Object.keys(domainsMap);
window.skillLabels = skillLabels;
