// Stockage local MathArthur
window.Storage = {
  key: 'matharthur_state_v1',
  defaultState(){
    return {
      player: { name:'Chevalier', level:1, xp:0, avatar:'av1', hat:null, pet:null, bg:'b1', effect:null },
      wallet: 0,
      owned: { avatars:['av1'], hats:[], pets:[], backgrounds:['b1'], effects:[] },
      equipped: { avatar:'av1', hat:null, pet:null, bg:'b1', effect:null },
      stats: { correct:0, wrong:0, streak:0, bestStreak:0, totalQuestions:0, byDomain:{} },
      progress: {}, // domain -> {completed, mastery}
      settings: { sound:true, speech:true, video:true, difficulty:2 },
      leaderboard: [],
      unlockedMultiplayer: false,
      dailyChallenge: null,
      lastVisit: null
    };
  },
  load(){
    try {
      const raw = localStorage.getItem(this.key);
      if(!raw) return this.defaultState();
      const s = JSON.parse(raw);
      // merge defaults
      const d = this.defaultState();
      return Object.assign(d, s, { player: Object.assign(d.player, s.player||{}), stats: Object.assign(d.stats, s.stats||{}), settings: Object.assign(d.settings, s.settings||{}) });
    } catch(e){ return this.defaultState(); }
  },
  save(state){ try { localStorage.setItem(this.key, JSON.stringify(state)); } catch(e){} },
  reset(){ localStorage.removeItem(this.key); }
};
window.state = window.Storage.load();
