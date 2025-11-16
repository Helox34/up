// routes/challenges.js
const express = require('express');
const router = express.Router();

// Mock data - w prawdziwej aplikacji pobierasz z bazy danych
const challenges = [
  {
    id: 'bench_press_proficiency',
    title: 'Bench Press Proficiency',
    subtitle: 'Maksymalne obciążenie w wyciskaniu leżąc',
    description: 'Osiągnij swoje maksimum w wyciskaniu leżąc',
    days: 30,
    progress: 0.0,
    difficulty: 'Trudny',
    type: 'proficiency',
    category: 'strength',
    target: { weight: 100 },
    current: { weight: 0 },
    unit: 'kg',
    icon: '🏋️',
    isJoined: false,
    isCompleted: false
  },
  // ... pozostałe wyzwania
];

// Pobierz wszystkie wyzwania
router.get('/', (req, res) => {
  res.json(challenges);
});

// Pobierz wyzwania użytkownika
router.get('/user/:userId', (req, res) => {
  const userChallenges = challenges.filter(c => c.isJoined);
  res.json(userChallenges);
});

// Dołącz do wyzwania
router.post('/:challengeId/join', (req, res) => {
  const { challengeId } = req.params;
  const { userId } = req.body;

  const challenge = challenges.find(c => c.id === challengeId);
  if (challenge) {
    challenge.isJoined = true;
    challenge.joinedAt = new Date();
    res.json({ success: true, challenge });
  } else {
    res.status(404).json({ error: 'Challenge not found' });
  }
});

// Aktualizuj postęp wyzwania
router.put('/:challengeId/progress', (req, res) => {
  const { challengeId } = req.params;
  const { progress, currentValue } = req.body;

  const challenge = challenges.find(c => c.id === challengeId);
  if (challenge) {
    challenge.progress = progress;
    challenge.current = { [Object.keys(challenge.current)[0]]: currentValue };
    challenge.isCompleted = progress >= 1.0;

    if (challenge.isCompleted) {
      challenge.completedAt = new Date();
    }

    res.json({ success: true, challenge });
  } else {
    res.status(404).json({ error: 'Challenge not found' });
  }
});

module.exports = router;