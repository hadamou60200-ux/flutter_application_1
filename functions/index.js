/**
 * Import function triggers from their respective submodules:
 */
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {setGlobalOptions} = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();
const db = admin.firestore();

// Contrôle global des instances
setGlobalOptions({ maxInstances: 10 });

// Fonction Cloud Callable sécurisée pour initier le paiement officiel
exports.createOfficialPayment = onCall(async (request) => {
  // 1. Vérifier que l'utilisateur est authentifié
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "L'utilisateur doit être connecté pour effectuer un paiement."
    );
  }

  const { reservationId, amount, currency, provider } = request.data;

  if (!reservationId || !amount || !provider) {
    throw new HttpsError(
      "invalid-argument",
      "Paramètres de paiement manquants."
    );
  }

  try {
    let paymentUrl = "";

    // 2. Gestion de l'API WAVE OFFICIELLE (Wave Checkout)
    if (provider === "wave") {
      const waveApiKey = process.env.WAVE_API_KEY; 

      const waveResponse = await axios.post(
        "https://api.wave.com/v1/checkout/sessions",
        {
          amount: amount.toString(),
          currency: currency || "XOF",
          error_url: "https://senride.app/payment-error",
          success_url: "https://senride.app/payment-success",
          client_reference: reservationId,
        },
        {
          headers: {
            Authorization: `Bearer ${waveApiKey}`,
            "Content-Type": "application/json",
          },
        }
      );

      paymentUrl = waveResponse.data.wave_launch_url;
    } 
    
    // 3. Gestion de l'API ORANGE MONEY (SONATEL) OFFICIELLE
    else if (provider === "orange") {
      const clientId = process.env.ORANGE_CLIENT_ID;
      const clientSecret = process.env.ORANGE_CLIENT_SECRET;
      const merchantKey = process.env.ORANGE_MERCHANT_KEY;

      // A. Obtenir le Token d'accès OAuth2 Orange
      const credentials = Buffer.from(`${clientId}:${clientSecret}`).toString("base64");
      const tokenResponse = await axios.post(
        "https://api.orange.com/oauth/v3/token",
        "grant_type=client_credentials",
        {
          headers: {
            Authorization: `Basic ${credentials}`,
            "Content-Type": "application/x-www-form-urlencoded",
          },
        }
      );

      const accessToken = tokenResponse.data.access_token;

      // B. Initier la demande de paiement Web/USSD
      const orangeResponse = await axios.post(
        "https://api.orange.com/orange-money-webpay/sn/v1/webpayment",
        {
          merchant_key: merchantKey,
          currency: "XOF",
          order_id: reservationId,
          amount: amount,
          return_url: "https://senride.app/payment-success",
          cancel_url: "https://senride.app/payment-error",
          lang: "fr",
        },
        {
          headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/json",
          },
        }
      );

      paymentUrl = orangeResponse.data.payment_url;
    } else {
      throw new HttpsError("invalid-argument", "Opérateur de paiement inconnu.");
    }

    // 4. Mettre à jour le statut de la réservation dans Firestore
    await db.collection("reservations").doc(reservationId).update({
      paymentProvider: provider,
      paymentStatus: "pending",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { paymentUrl };
  } catch (error) {
    console.error("Erreur API Paiement:", error.response?.data || error.message);
    throw new HttpsError(
      "internal",
      `Échec de l'initialisation du paiement : ${error.message}`
    );
  }
});