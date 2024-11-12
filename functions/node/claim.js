const admin = require("firebase-admin");
admin.initializeApp();
const functions = require("firebase-functions");


exports.setCustomClaim = functions.https.onCall(async (data, context) => {
    const uid = data.uid;
    const clientType = data.clientType; // e.g., CLIENT_TYPE_WEB or CLIENT_TYPE_MOBILE

    if (!context.auth) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'Only authenticated users can add custom claims.'
        );
    }

    try {
        await admin.auth().setCustomUserClaims(uid, { clientType: clientType });
        return { message: `Custom claim ${clientType} added for user ${uid}` };
    } catch (error) {
        throw new functions.https.HttpsError('internal', error.message);
    }
});