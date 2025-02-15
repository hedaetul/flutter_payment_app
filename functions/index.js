const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendTransactionNotification = functions.firestore
  .document('users/{userId}/transactions/{transactionId}')
  .onCreate(async (snap, context) => {
    const transactionData = snap.data();
    const receiverId = transactionData.counterUid;
    const senderId = context.params.userId;

    const senderDoc = await admin.firestore().doc(`users/${senderId}`).get();
    const receiverDoc = await admin
      .firestore()
      .doc(`users/${receiverId}`)
      .get();

    const senderToken = senderDoc.data().fcmToken;
    const receiverToken = receiverDoc.data().fcmToken;

    const message = {
      notification: {
        title: 'Transaction Alert',
        body: `Transaction of \$${transactionData.amount} ${
          transactionData.transactionType === 'cash-in' ? 'received' : 'sent'
        }.`,
      },
    };

    if (senderToken) {
      await admin.messaging().sendToDevice(senderToken, message);
    }
    if (receiverToken) {
      await admin.messaging().sendToDevice(receiverToken, message);
    }

    return null;
  });
