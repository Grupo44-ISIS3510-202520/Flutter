const {onSchedule} = require("firebase-functions/v2/scheduler");
const {getFirestore, Timestamp} = require("firebase-admin/firestore");

function getWeekId() {
  const now = new Date();
  const onejan = new Date(now.getFullYear(), 0, 1);
  const week = Math.ceil(
    (((now - onejan) / 86400000) + onejan.getDay() + 1) / 7
  );
  return `${now.getFullYear()}-W${week}`;
}

exports.generateWeeklyLeaderboard = onSchedule(
  {
    schedule: "59 23 * * SUN",
    timeZone: "America/Bogota",
    region: "us-central1",
  },
  async () => {
    console.log("Generating weekly leaderboard…");

    const db = getFirestore();

    try {
      const weekId = getWeekId();
      console.log(`Computed weekId: ${weekId}`);

      const usersSnap = await db.collection("users").get();
      const trainingsSnap = await db.collection("user_trainings").get();

      const entries = [];

      trainingsSnap.forEach((doc) => {
        const uid = doc.id;
        const data = doc.data();

        let completedCount = 0;
        let lastCompletedAt = null;

        for (const [key, value] of Object.entries(data)) {
          if (value && value.percent === 100) {
            completedCount++;

            if (value.completedAt && value.completedAt.toDate) {
              const completedDate = value.completedAt.toDate();
              if (!lastCompletedAt || completedDate > lastCompletedAt) {
                lastCompletedAt = completedDate;
              }
            }
          }
        }

        if (completedCount === 0) return;

        const userDoc = usersSnap.docs.find((u) => u.id === uid);
        if (!userDoc) return;

        const email = userDoc.data().email || "unknown";
        const emailPrefix = email.split("@")[0];

        entries.push({
          uid,
          emailPrefix,
          completedCount,
          lastCompletedAt: lastCompletedAt
            ? Timestamp.fromDate(lastCompletedAt)
            : null,
        });
      });

      entries.sort((a, b) => {
        if (b.completedCount !== a.completedCount) {
          return b.completedCount - a.completedCount;
        }

        if (a.lastCompletedAt && b.lastCompletedAt) {
          return (
            a.lastCompletedAt.toMillis() -
            b.lastCompletedAt.toMillis()
          );
        }

        return 0;
      });

      const top10 = entries.slice(0, 10);

      await db
        .collection("weekly_leaderboard")
        .doc(weekId)
        .set({
          generatedAt: Timestamp.now(),
          entries: top10,
        });

      console.log(`Weekly leaderboard written for ${weekId}`);
    } catch (err) {
      console.error("Error generating leaderboard:", err);
    }
  }
);
