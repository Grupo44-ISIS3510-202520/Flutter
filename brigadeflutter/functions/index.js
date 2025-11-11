/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();

/**
 * Envía notificación push cuando se crea una nueva alerta
 */
exports.sendAlertNotification = onDocumentCreated(
    "alerts/{alertId}",
    async (event) => {
        const snapshot = event.data;
        if (!snapshot) {
            console.log("No hay datos en el snapshot");
            return;
        }

        const alertData = snapshot.data();
        const alertId = event.params.alertId;

        const title = alertData.title || "New alert";
        const message = alertData.message || "An emergency has been reported.";

        console.log(`New Alert: ${title}`);
        console.log(` Alert ID: ${alertId}`);

        // Mensaje para FCM
        const fcmMessage = {
            notification: {
                title: title,
                body: message,
            },
            data: {
                title: title,
                message: message,
                type: alertData.type || "info",
                alertId: alertId,
                timestamp: alertData.timestamp?.toString() || Date.now().toString(),
            },
            android: {
                priority: "high",
                notification: {
                    channelId: "alerts_channel",
                    priority: "high",
                    defaultSound: true,
                    defaultVibrateTimings: true,
                },
            },
            topic: "alerts",
        };

        try {
            const response = await getMessaging().send(fcmMessage);
            console.log("Notificación enviada exitosamente:", response);
            return {success: true, messageId: response};
        } catch (error) {
            console.error("Error enviando notificación:", error);
            return {success: false, error: error.message};
        }
    },
);