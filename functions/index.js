const {onDocumentCreated, onDocumentWritten} = require('firebase-functions/v2/firestore');
const {onRequest} = require('firebase-functions/v2/https');
const {getFirestore} = require('firebase-admin/firestore');
const {initializeApp} = require('firebase-admin/app');
const {getMessaging} = require('firebase-admin/messaging');

initializeApp();

// Soru eklendiğinde uygun kullanıcıların inbox'una kopya ekler
exports.matchQuestionToUsers = onDocumentCreated({
  region: 'europe-west3',
  document: 'questions/{questionId}'
}, async (event) => {
  const question = event.data.data();
  if (!question) return;
  const db = getFirestore();
  const filters = question.filters || {};
  const usersRef = db.collection('users');
  let query = usersRef;
  if (filters.gender) query = query.where('gender', '==', filters.gender);
  if (filters.city) query = query.where('sehir', '==', filters.city);
  if (filters.minAge || filters.maxAge) {
    const now = new Date();
    if (filters.minAge) {
      const maxBirth = new Date(now.getFullYear() - filters.minAge, now.getMonth(), now.getDate());
      query = query.where('birthDate', '<=', maxBirth);
    }
    if (filters.maxAge) {
      const minBirth = new Date(now.getFullYear() - filters.maxAge, now.getMonth(), now.getDate());
      query = query.where('birthDate', '>=', minBirth);
    }
  }
  const usersSnap = await query.get();
  const batch = db.batch();
  usersSnap.forEach(userDoc => {
    const inboxRef = userDoc.ref.collection('inbox').doc(event.params.questionId);
    batch.set(inboxRef, {
      questionId: event.params.questionId,
      questionText: question.questionText,
      status: question.status,
      timestamp: question.timestamp,
    });
  });
  await batch.commit();
});

// Yeni cevap eklendiğinde soru sahibine FCM bildirimi gönderir
exports.yeniCavapBildirimi = onDocumentCreated({
  region: 'europe-west3',
  document: 'questions/{questionId}/answers/{answerId}'
}, async (event) => {
  const answer = event.data.data();
  if (!answer) return;
  const db = getFirestore();
  const questionSnap = await db.collection('questions').doc(event.params.questionId).get();
  const question = questionSnap.data();
  if (!question) return;
  const askerId = question.askerId;
  const userSnap = await db.collection('users').doc(askerId).get();
  const user = userSnap.data();
  if (!user || !user.fcmToken) return;
  await getMessaging().send({
    token: user.fcmToken,
    notification: {
      title: 'Yeni Cevap!',
      body: 'Sorunuza yeni bir cevap geldi.',
    },
    data: {
      questionId: event.params.questionId,
    },
  });
}); 