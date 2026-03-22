/*
  Firebase Messaging service worker.
  Replace config values with your Firebase web app credentials.
*/

importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: self.FIREBASE_WEB_API_KEY || '',
  authDomain: self.FIREBASE_WEB_AUTH_DOMAIN || '',
  projectId: self.FIREBASE_WEB_PROJECT_ID || '',
  storageBucket: self.FIREBASE_WEB_STORAGE_BUCKET || '',
  messagingSenderId: self.FIREBASE_WEB_MESSAGING_SENDER_ID || '',
  appId: self.FIREBASE_WEB_APP_ID || '',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
  const title = payload.notification?.title || 'Tutta';
  const options = {
    body: payload.notification?.body || 'You have a new message',
    data: payload.data || {},
  };

  self.registration.showNotification(title, options);
});
