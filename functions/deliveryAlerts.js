const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');

// 🔥 Naya order aane par online delivery boys ko alert bhejna
exports.sendOrderNotification = functions.firestore
    .document('All_Orders/{orderId}')
    .onCreate(async (snapshot, context) => {
        const orderData = snapshot.data();

        // 1. Un sabhi online delivery partners ke tokens nikalna
        const drivers = await admin.firestore().collection('Users')
            .where('role', '==', 'delivery')
            .where('isOnline', '==', true)
            .get();

        const tokens = [];
        drivers.forEach(doc => {
            if (doc.data().userDeviceToken) {
                tokens.push(doc.data().userDeviceToken);
            }
        });

        // 2. Agar koi driver milta hai, toh use notification bhejna
        if (tokens.length > 0) {
            const message = {
                notification: {
                    title: 'New Order Alert! 🔔',
                    body: `Naya order aaya hai ₹${orderData.totalAmount || 'kuch'} ka. Turant check karein!`,
                },
                tokens: tokens,
            };
            return admin.messaging().sendEachForMulticast(message);
        } else {
            console.log("No online drivers found.");
            return null;
        }
    });