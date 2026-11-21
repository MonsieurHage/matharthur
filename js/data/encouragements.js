// Mots d'encouragement MathArthur
window.ENCOURAGEMENTS = {
  correct: [
    "Bravo champion ! 🏆","Excellent ! Tu es un vrai chevalier ! ⚔️","Magnifique ! Continue comme ça ! ✨",
    "Super ! Tu maîtrises bien ça ! 💪","Fantastique ! Le royaume est fier de toi ! 🏰",
    "Parfait ! Tu progresses à vitesse grand V ! 🚀","Incroyable ! Encore un point pour le héros ! 🦸",
    "Bravo ! Ton intelligence brille comme une étoile ! ⭐","Génial ! Tu es sur la bonne voie ! 🛤️",
    "Oui ! Continue, tu es unstoppable ! 🔥"
  ],
  wrong: [
    "Pas grave, on réessaie ! 💡","Presque ! Tu vas y arriver ! 🌟","Courage, chaque erreur est un apprentissage ! 📚",
    "Ne te décourage pas, le héros apprend de ses erreurs ! ⚔️","C'est en forgeant qu'on devient forgeron ! 🔨",
    "Essaie encore, tu es capable ! 💪","Pas de panique, l'erreur fait partie du jeu ! 🎮"
  ],
  streak: [
    "🔥 Série de {n} ! Tu es en feu !",
    "⚡ {n} bonnes réponses d'affilée ! Incroyable !",
    "🌟 Combo x{n} ! Le royaume tremble !"
  ],
  levelup: [
    "🎉 NIVEAU SUPÉRIEUR ! Tu es maintenant niveau {n} !",
    "👑 Félicitations ! Niveau {n} atteint !"
  ],
  lowTime: ["⏰ Vite, le temps presse !","⏳ Dépêche-toi, chevalier !"],
  hint: ["💡 Voici un indice pour t'aider","🤔 Réfléchis bien..."],
  welcome: ["Bienvenue dans le Royaume des Maths ! 🏰","Prêt à conquérir les nombres ? ⚔️"],
  goodbye: ["À bientôt, chevalier ! 👋","Reviens vite progresser ! 🌟"]
};

window.randomEncouragement = function(type){
  const arr = window.ENCOURAGEMENTS[type] || window.ENCOURAGEMENTS.correct;
  return arr[Math.floor(Math.random()*arr.length)];
};
