const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
const db = admin.firestore();

// 🔥 SMART SCANNER: Ye array aur main document dono mein 'uploadedBy' dhoondhega
function getVendorIds(orderData) {
    let vendors = [];

    if (orderData.uploadedBy) {
        vendors.push(orderData.uploadedBy);
    }

    if (orderData.items && Array.isArray(orderData.items)) {
        orderData.items.forEach(item => {
            if (item.uploadedBy) {
                vendors.push(item.uploadedBy);
            }
        });
    }

    return [...new Set(vendors.filter(id => id != null))];
}

// 1. NAYA ORDER AANE PAR (Store_Orders listen karega)
exports.sendNewOrderNotification = functions.firestore
    .document('Store_Orders/{orderId}')
    .onCreate(async (snap, context) => {
        const orderData = snap.data();
        const orderId = context.params.orderId;
        const vendorId = orderData.vendorId; // 🔥 Ab Store_Orders mein seedha vendorId hoga

        console.log(`🔥 [NEW STORE ORDER] ID: ${orderId} | Vendor: ${vendorId}`);

        if (vendorId) {
            const vendorDoc = await db.collection('Users').doc(vendorId).get();
            if (vendorDoc.exists && vendorDoc.data().userDeviceToken) {
                const token = vendorDoc.data().userDeviceToken;

                const message = {
                    notification: {
                        title: "🎉 New Order for your Store!",
                        body: `Naya order aaya hai! Order ID: #${orderId.substring(0, 6)}`,
                    },
                    token: token
                };

                try {
                    await admin.messaging().send(message);
                    console.log(`✅ Notification sent to Vendor: ${vendorId}`);
                } catch (error) {
                    console.error(`❌ Error sending notification:`, error);
                }
            }
        }
        return null;
    });
// 2. STATUS CHANGE HONE PAR (Store_Orders listen karega)
exports.sendOrderStatusUpdate = functions.firestore
    .document('Store_Orders/{orderId}')
    .onUpdate(async (change, context) => {
        const newData = change.after.data();
        const oldData = change.before.data();
        const orderId = context.params.orderId;
        const vendorId = newData.vendorId;

        if (newData.status !== oldData.status) {
            console.log(`🔄 [STATUS UPDATE] Order: ${orderId} | New Status: ${newData.status}`);

            const vendorDoc = await db.collection('Users').doc(vendorId).get();
            if (vendorDoc.exists && vendorDoc.data().userDeviceToken) {
                const token = vendorDoc.data().userDeviceToken;

               const message = {
                                   notification: {
                                       title: "📦 Order Status Updated",
                                       body: `Order #${orderId.substring(0, 6)} status changed to '${newData.status}'`, // 👈 NAYA BACKTICK LAGA DIYA HAI
                                   },
                                   token: token
                               };

                try {
                    await admin.messaging().send(message);
                    console.log(`✅ Success! Status update notification sent.`);
                } catch (error) {
                    console.error(`❌ Error sending notification:`, error);
                }
            }
        }
        return null;
    });
// 3. 🔥 NAYA INSTANT LOW STOCK ALERT (Normal Test Ke Liye)
exports.testLowStockAlert = functions.firestore
    .document('Products/{productId}')
    .onUpdate(async (change, context) => {
        const newData = change.after.data();
        const oldData = change.before.data();

        // Check: Agar tune stock change kiya hai AUR naya stock 5 se kam hai
        if (newData.stock !== oldData.stock && newData.stock < 5) {
            console.log(`⚠️ [LOW STOCK TRIGGER] Product: ${newData.title} | Stock: ${newData.stock}`);

            const vendorId = newData.uploadedBy;
            if (!vendorId) {
                console.log("❌ Is product mein 'uploadedBy' ki ID nahi hai!");
                return null;
            }

            const vendorDoc = await db.collection('Users').doc(vendorId).get();
            if (vendorDoc.exists && vendorDoc.data().userDeviceToken) {
                const token = vendorDoc.data().userDeviceToken;

                const message = {
                    notification: {
                        title: "⚠️ CRITICAL: Low Stock Alert!",
                        body: `Bhai! Tere product '${newData.title}' ka stock sirf ${newData.stock} bacha hai!`,
                    },
                    token: token
                };

                try {
                    console.log(`🚀 Sending Low Stock Alert to Token: ${token}`);
                    await admin.messaging().send(message);
                    console.log(`✅ Success! Low Stock Notification sent.`);
                } catch (error) {
                    console.error(`❌ Error sending low stock alert:`, error);
                }
            } else {
                console.log(`⚠️ Vendor ka token nahi mila database mein!`);
            }
        }
        return null;
    });