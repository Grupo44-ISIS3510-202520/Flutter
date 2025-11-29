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

        const title = alertData.title || "Nueva Alerta";
        const message = alertData.message || "Se ha reportado una emergencia";

        console.log(`Nueva alerta creada: ${title}`);
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

exports.generateWeeklyLeaderboard = require("./leaderboard").generateWeeklyLeaderboard;
