/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */
const admin = require("firebase-admin");
const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
admin.initializeApp();

const functions = require('firebase-functions');
const payment = require('./node/payment');
const claim = require('./node/claim');

// Export individual functions here
exports.setCustomClaim = claim.setCustomClaim;
exports.checkPayment = payment.checkPayment;
