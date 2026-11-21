// Moteur d'adaptive learning MathArthur
// Respecte la Zone Proximale de Développement (Vygotsky) : questions ni trop faciles ni trop difficiles,
// avec scaffolding (indices, explications) et progression par maîtrise.

window.Adaptive = {
  // Maîtrise par domaine et compétence (0..1)
  mastery(state, domain){ 
    const p = state.progress[domain];
    return p ? (p.mastery||0) : 0;
  },
  // Niveau de difficulté cible (1..5) selon maîtrise et performance récente
  targetDifficulty(state, domain){
    const m = this.mastery(state, domain);
    const streak = state.stats.streak || 0;
    let d = 1 + Math.round(m*4); // 1..5
    // Zone proximale : on vise juste au-dessus de la maîtrise actuelle
    d = Math.min(5, d+1);
    // Ajustement par streak : si en feu, monte; si en difficulté, descend
    if(streak >= 5) d = Math.min(5, d+1);
    if(streak === 0 && state.stats.wrong > state.stats.correct) d = Math.max(1, d-1);
    // Paramètre utilisateur
    d = Math.round((d + (state.settings.difficulty||2))/2);
    return Math.max(1, Math.min(5, d));
  },
  // Sélectionne une question adaptée
  pickQuestion(state, domain, excludeIds){
    excludeIds = excludeIds || [];
    const targetD = this.targetDifficulty(state, domain);
    let pool = window.MATHARTHUR_QUESTIONS.filter(q => q.domain===domain && !excludeIds.includes(q.id));
    if(domain==='Tous') pool = window.MATHARTHUR_QUESTIONS.filter(q => !excludeIds.includes(q.id));
    // Générer des questions d'opérations pour variété
    if(Math.random()<0.35 && (domain==='Nombres et calculs' || domain==='Tous')){
      pool.push(window.generateOperationQuestion(targetD));
    }
    // Filtrer par difficulté proche de la cible (ZPD : ±1)
    let candidates = pool.filter(q => Math.abs(q.difficulty-targetD)<=1);
    if(candidates.length===0) candidates = pool;
    // Privilégier les compétences les moins maîtrisées
    // (simple pondération)
    const pick = candidates[Math.floor(Math.random()*candidates.length)];
    return pick;
  },
  // Met à jour la maîtrise après réponse
  update(state, question, correct){
    const domain = question.domain;
    if(!state.progress[domain]) state.progress[domain] = { completed:0, mastery:0, attempts:0, correct:0 };
    const p = state.progress[domain];
    p.attempts = (p.attempts||0)+1;
    if(correct){ p.correct=(p.correct||0)+1; p.completed=(p.completed||0)+1; }
    // Maîtrise lissée (moyenne mobile)
    const acc = p.correct / p.attempts;
    p.mastery = 0.7*p.mastery + 0.3*acc;
    // XP
    const xpGain = correct ? (10 + question.difficulty*5 + (state.stats.streak||0)*2) : 2;
    state.player.xp += xpGain;
    // Level up
    const xpNeeded = state.player.level*100;
    if(state.player.xp >= xpNeeded){
      state.player.level += 1;
      state.player.xp -= xpNeeded;
      return { levelUp: true, newLevel: state.player.level };
    }
    return { levelUp: false };
  },
  // Recommandation de domaine le moins maîtrisé
  weakestDomain(state){
    let min=1, dom=null;
    window.MATHARTHUR_DOMAINS.forEach(d=>{
      const m = this.mastery(state,d);
      if(m < min){ min=m; dom=d; }
    });
    return dom || window.MATHARTHUR_DOMAINS[0];
  },
  // Scaffolding : indice progressif
  scaffold(question, level){
    // level 0: rien, 1: indice, 2: explication partielle
    if(level===1) return question.hint;
    if(level===2) return "Indice : " + question.hint + " | Réponse proche de " + question.answers[question.correct];
    return null;
  }
};
