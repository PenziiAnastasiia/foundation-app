const admin = require('firebase-admin');

// Налаштування для емулятора
process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST = 'localhost:9099';

admin.initializeApp({
  projectId: 'demo-project',
});

const db = admin.firestore();

async function runTest() {
  console.log('Запуск тесту тригерів...');
  
  try {
    // Перевірка підключення
    console.log('\nПеревірка підключення до Firestore...');
    await db.collection('_test').doc('connection').set({ 
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      status: 'connected' 
    });
    console.log('Є підключення до Firestore.');

    // Створення користувача
    console.log('\nСтворення тестового користувача...');
    await db.collection('Users').doc('testUser').set({
      name: 'Test User',
      fcmToken: 'test-token-123'
    });
    console.log('Користувач створений.');

    // Створення збору (має спрацювати тригер)
    console.log('\nСтворення тестового збору...');
    const fundraiserRef = await db.collection('Fundraisers').add({
      title: 'Тестовий збір'
    });
    console.log('Збір створений з ID:', fundraiserRef.id);

    // Очікування на спрацювання тригера на додавання нового збору
    console.log('\nОчікування на спрацювання тригера...');
    await new Promise(resolve => setTimeout(resolve, 5000));

  
    // Створення тестового донату користувача
    console.log('\nСтворення тестового донату у користувача...');
    await db.collection('Users/testUser/Donations').add({
      fundraiserId: fundraiserRef.id,
      amount: 100,
      date: admin.firestore.FieldValue.serverTimestamp()
    });
    console.log('Донат створено.');

    // Створення звіту (має спрацювати другий тригер)
    console.log('\nСтворення тестового звіту...');
    await db.collection('Reports').add({
      fundraiserId: fundraiserRef.id,
      title: 'Тестовий звіт'
    });
    console.log('Звіт створено.');

    // Очікування на спрацювання тригера на додавання нового звіту
    console.log('\nОчікування на спрацювання тригера...');
    await new Promise(resolve => setTimeout(resolve, 5000));

    console.log('Тест завершено. Результати спрацювання тригерів в логах емулятора.');

  } catch (error) {
    console.error('Помилка в тесті:', error);
  } finally {
    process.exit(0);
  }
}

runTest();