const admin = require("firebase-admin");

// Debug: Check environment variables
console.log("Firebase Configuration Check:", {
  projectId: process.env.FIREBASE_PROJECT_ID,
  clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
  privateKey: process.env.FIREBASE_PRIVATE_KEY ? "***exists***" : "MISSING",
  hasServiceAccount: process.env.FIREBASE_SERVICE_ACCOUNT_KEY
    ? "***exists***"
    : "MISSING",
});

if (!admin.apps.length) {
  try {
    let credential;

    // Option 1: Using service account key file (recommended)
    if (process.env.FIREBASE_SERVICE_ACCOUNT_KEY) {
      const serviceAccount = JSON.parse(
        process.env.FIREBASE_SERVICE_ACCOUNT_KEY
      );
      credential = admin.credential.cert(serviceAccount);
      console.log("✅ Using SERVICE_ACCOUNT_KEY");
    }
    // Option 2: Using individual environment variables
    else if (
      process.env.FIREBASE_PROJECT_ID &&
      process.env.FIREBASE_PRIVATE_KEY &&
      process.env.FIREBASE_CLIENT_EMAIL
    ) {
      const firebaseConfig = {
        type: "service_account",
        project_id: process.env.FIREBASE_PROJECT_ID,
        private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
        private_key: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n"),
        client_email: process.env.FIREBASE_CLIENT_EMAIL,
        client_id: process.env.FIREBASE_CLIENT_ID,
        auth_uri: "https://accounts.google.com/o/oauth2/auth",
        token_uri: "https://oauth2.googleapis.com/token",
        auth_provider_x509_cert_url:
          "https://www.googleapis.com/oauth2/v1/certs",
        client_x509_cert_url: `https://www.googleapis.com/robot/v1/metadata/x509/${encodeURIComponent(
          process.env.FIREBASE_CLIENT_EMAIL
        )}`,
      };
      credential = admin.credential.cert(firebaseConfig);
      console.log("✅ Using individual environment variables");
    } else {
      throw new Error("Firebase credentials not properly configured");
    }

    // Initialize Firebase Admin SDK (Auth Only)
    admin.initializeApp({
      credential: credential,
      projectId: process.env.FIREBASE_PROJECT_ID,
    });

    console.log("✅ Firebase Auth initialized successfully");
  } catch (error) {
    console.error("❌ Firebase initialization error:", error.message);
    throw error;
  }
}

// Helper functions for Firebase Auth operations
const firebaseHelpers = {
  // Create user
  async createUser(userData) {
    try {
      const userRecord = await admin.auth().createUser(userData);
      console.log(`✅ Firebase user created: ${userRecord.uid}`);
      return userRecord;
    } catch (error) {
      console.error("❌ Error creating Firebase user:", error.message);
      throw error;
    }
  },

  // Get user by UID
  async getUser(uid) {
    try {
      const userRecord = await admin.auth().getUser(uid);
      return userRecord;
    } catch (error) {
      console.error(`❌ Error getting user ${uid}:`, error.message);
      throw error;
    }
  },

  // Update user
  async updateUser(uid, userData) {
    try {
      const userRecord = await admin.auth().updateUser(uid, userData);
      console.log(`✅ Firebase user updated: ${uid}`);
      return userRecord;
    } catch (error) {
      console.error(`❌ Error updating user ${uid}:`, error.message);
      throw error;
    }
  },

  // Delete user
  async deleteUser(uid) {
    try {
      await admin.auth().deleteUser(uid);
      console.log(`✅ Firebase user deleted: ${uid}`);
      return true;
    } catch (error) {
      console.error(`❌ Error deleting user ${uid}:`, error.message);
      throw error;
    }
  },

  // Verify ID token
  async verifyIdToken(idToken) {
    try {
      const decodedToken = await admin.auth().verifyIdToken(idToken);
      return decodedToken;
    } catch (error) {
      console.error("❌ Error verifying ID token:", error.message);
      throw error;
    }
  },

  // List users (for debugging)
  async listUsers(maxResults = 10) {
    try {
      const listUsersResult = await admin.auth().listUsers(maxResults);
      return listUsersResult;
    } catch (error) {
      console.error("❌ Error listing users:", error.message);
      throw error;
    }
  },
};

// Export both admin and helpers
module.exports = admin;
module.exports.firebaseHelpers = firebaseHelpers;
