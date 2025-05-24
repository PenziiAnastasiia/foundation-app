const {logger} = require("firebase-functions");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {messaging} = require("firebase-admin/messaging");

initializeApp();

exports.notifyNewFundraiser = onDocumentCreated(
    {
      region: "europe-central2",
      document: "Fundraisers/{fundraiserId}",
    },
    async (event) => {
      try {
        if (!event.data) {
          logger.warn("Спрацював тригер без даних документа");
          return;
        }

        const fundraiserData = event.data.data();
        if (!fundraiserData) {
          logger.warn("Дані документа відсутні");
          return;
        }

        const fundraiserTitle = fundraiserData.title || "Без назви";
        const db = getFirestore();

        logger.log("Спрацював тригер для нового збору:", fundraiserTitle);

        const usersSnapshot = await db.collection("Users").get();
        const tokens = [];

        usersSnapshot.docs.forEach((doc) => {
          const userData = doc.data();
          const token = userData.fcmToken;
          if (token) {
            tokens.push(token);
          }
        });

        logger.log("Додано збір:", fundraiserTitle);
        logger.log("Користувачі, яких треба сповістити:", tokens.length);

        // Для відправки повідомлень (закоментувати):
        return Promise.resolve();

        // Для відправки повідомлень (розкоментувати):
        // return messaging().sendEachForMulticast({
        //   tokens: tokens,
        //   notification: {
        //     title: "Новий збір відкрито!",
        //     body: `Долучись до збору "${fundraiserTitle}"`,
        //   },
        // });
      } catch (error) {
        logger.error("Помилка в notifyNewFundraiser:", error);
        throw error;
      }
    },
);

exports.notifyNewReport = onDocumentCreated(
    {
      region: "europe-central2",
      document: "Reports/{reportId}",
    },
    async (event) => {
      try {
        if (!event.data) {
          logger.warn("Спрацював тригер без даних документа");
          return;
        }

        const reportData = event.data.data();
        if (!reportData) {
          logger.warn("Дані звіту відсутні");
          return;
        }

        const reportId = event.params.reportId;
        const fundraiserId = reportData.fundraiserId;

        if (!fundraiserId) {
          logger.error("У звіті відсутній fundraiserId");
          return;
        }

        logger.log("Спрацював тригер для нового звіту:", reportId,
            "для збору:", fundraiserId);

        const db = getFirestore();
        const usersSnapshot = await db.collection("Users").get();
        const tokens = [];

        for (const userDoc of usersSnapshot.docs) {
          try {
            const donations = await db
                .collection(`Users/${userDoc.id}/Donations`)
                .where("fundraiserId", "==", fundraiserId)
                .get();

            const userData = userDoc.data();
            const token = userData.fcmToken;

            if (!donations.empty && token) {
              tokens.push(token);
              logger.log(`Користувач ${userDoc.id} підтримував збір.`);
            }
          } catch (donationError) {
            logger.warn("Помилка при перевірці донатів:", donationError);
          }
        }

        logger.log("Додано звіт на збір:", fundraiserId);
        logger.log("Користувачі, яких треба сповістити:", tokens.length);

        // Для відправки повідомлень (закоментувати):
        return Promise.resolve();

        // Для відправки повідомлень (розкоментувати):
        // return messaging().sendEachForMulticast({
        //   tokens: tokens,
        //   notification: {
        //     title: "Звіт по збору",
        //     body: `Зʼявився новий звіт по збору, який ти підтримав(ла).`,
        //   },
        // });
      } catch (error) {
        logger.error("Помилка в notifyNewReport:", error);
        throw error;
      }
    },
);
