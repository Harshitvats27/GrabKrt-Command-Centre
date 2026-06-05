const admin = require("firebase-admin");
admin.initializeApp(); // 👈 Firebase sirf ek baar yahan initialize hoga

// 1. Saari alag-alag files ko import karo
const adminAlerts = require("./adminAlerts");
const deliveryAlerts = require("./deliveryAlerts");
const userAlerts = require("./userAlerts"); // 🔥 NAYI FILE: User App ke liye

// 2. Firebase ko functions bhej do
exports.adminApp = adminAlerts;
exports.deliveryApp = deliveryAlerts;
exports.userApp = userAlerts; // 🔥 User app export ho gaya