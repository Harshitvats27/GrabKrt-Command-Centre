const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
const db = admin.firestore();

// ==========================================
// 1. NAYA ORDER PLACE HONE PAR (Master Order)
// ==========================================
exports.userNewOrderAlert = functions.firestore
    .document('Users/{userId}/Orders/{orderId}')
    .onCreate(async (snap, context) => {
        const userId = context.params.userId;
        const orderId = context.params.orderId;

        // 1. User ka token nikalna
        const userDoc = await db.collection('Users').doc(userId).get();
        if (!userDoc.exists || !userDoc.data().userDeviceToken) {
            console.log(`❌ User ${userId} ka token nahi mila`);
            return null;
        }
        const token = userDoc.data().userDeviceToken;

        // 2. Notification Message Banao
        const message = {
            notification: {
                title: "Order Placed Successfully! 🎉",
                body: `Congratulations! Your order #${orderId.substring(0, 6)} is Successfully Placed----Keep Shopping!!`,
            },
            token: token
        };

        // 3. Notification Bhej do
        try {
            await admin.messaging().send(message);
            console.log(`✅ New order notification sent to Customer: ${userId}`);
        } catch (error) {
            console.error(`❌ Error sending new order notification:`, error);
        }
        return null;
    });

// ==========================================
// 2. ORDER STATUS CHANGE HONE PAR (Sub-Order)
// ==========================================
exports.sendUserOrderStatusUpdate = functions.firestore
    .document('Store_Orders/{subOrderId}')
    .onUpdate(async (change, context) => {
        const newData = change.after.data();
        const oldData = change.before.data();
        const subOrderId = context.params.subOrderId;

        // 1. Check karo ki kya status sach mein change hua hai?
        const newStatus = newData.status;
        const oldStatus = oldData.status;

        if (newStatus !== oldStatus) {
            console.log(`🔄 [USER ALERT] Order ${subOrderId} status changed to ${newStatus}`);

            const userId = newData.userId; // Master Order wale customer ki ID

            if (!userId) {
                console.log("❌ Is order mein Customer ki ID (userId) nahi mili!");
                return null;
            }

            // 2. Customer ka token fetch karo 'Users' collection se
            const userDoc = await db.collection('Users').doc(userId).get();

            if (userDoc.exists && userDoc.data().userDeviceToken) {
                const token = userDoc.data().userDeviceToken;

                // 3. Notification Message Banao
                const message = {
                    notification: {
                        title: "📦 Order Update!",
                        body: `Aapke ${newData.storeName || 'order'} ka status ab '${newStatus}' ho gaya hai.`,
                    },
                    token: token
                };

                // 4. Notification Bhej do
                try {
                    await admin.messaging().send(message);
                    console.log(`✅ Status update notification sent to Customer: ${userId}`);
                } catch (error) {
                    console.error(`❌ Error sending status update notification:`, error);
                }
            } else {
                console.log(`⚠️ Customer (${userId}) ka device token database mein nahi mila!`);
            }
        }
        return null;
    });