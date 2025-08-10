const bcrypt = require("bcryptjs");
const { v4: uuidv4 } = require("uuid");
const prisma = require("../config/database");
const admin = require("../config/firebase");
const { UnauthorizedError, ValidationError } = require("../utils/errors");
const { USER_ROLES } = require("../utils/constants");

class AuthService {
  // Register new user (web admin) - Firebase Auth Only
  async register({ email, password, name, role = USER_ROLES.CITIZEN }) {
    console.log("🚀 Starting registration process for:", email);

    // Check if user exists in local database
    const existingUser = await prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw new ValidationError("Email already registered");
    }

    let firebaseUser = null;
    let firebaseUid = null;

    try {
      console.log("📝 Step 1: Creating Firebase Authentication user...");

      // 1. Create user in Firebase Authentication
      firebaseUser = await admin.auth().createUser({
        email,
        password,
        displayName: name,
        emailVerified: false,
      });

      firebaseUid = firebaseUser.uid;
      console.log("✅ Firebase user created successfully!");
      console.log("   - Firebase UID:", firebaseUid);
      console.log("   - Email:", firebaseUser.email);
      console.log("   - Display Name:", firebaseUser.displayName);

      console.log("📝 Step 2: Hashing password for local database...");

      // 2. Hash password for local database
      const hashedPassword = await bcrypt.hash(password, 12);

      console.log("📝 Step 3: Creating user in local database...");

      // 3. Create user in local database
      const user = await prisma.user.create({
        data: {
          email,
          name,
          role,
          password: hashedPassword,
          firebaseUid: firebaseUid,
          isActive: true,
          points: 0,
        },
        select: {
          id: true,
          email: true,
          name: true,
          role: true,
          firebaseUid: true,
          createdAt: true,
        },
      });

      console.log("✅ User saved to local database successfully!");
      console.log("   - Local User ID:", user.id);
      console.log("   - Firebase UID:", user.firebaseUid);

      console.log("🎉 Registration completed successfully for:", email);
      return user;
    } catch (error) {
      console.error("❌ Registration error:", error);
      console.error("   Error message:", error.message);
      console.error("   Error code:", error.code);

      // Rollback: If local database save fails but Firebase user was created
      if (firebaseUid) {
        try {
          console.log("🔄 Rolling back: Deleting Firebase user...");
          await admin.auth().deleteUser(firebaseUid);
          console.log("✅ Firebase user deleted due to registration error");
        } catch (deleteError) {
          console.error("❌ Error during rollback:", deleteError.message);
        }
      }

      // If it's a Firebase error, throw a more user-friendly message
      if (error.code === "auth/email-already-exists") {
        throw new ValidationError("Email already registered in Firebase");
      }

      throw error instanceof ValidationError
        ? error
        : new ValidationError(`Registration failed: ${error.message}`);
    }
  }

  // Login with email/password (web admin)
  async loginWithPassword({ email, password }) {
    const user = await prisma.user.findUnique({
      where: { email },
    });

    if (!user || !user.isActive) {
      throw new UnauthorizedError("Invalid credentials");
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedError("Invalid credentials");
    }

    // Check role permissions
    if (
      user.role !== USER_ROLES.STAKEHOLDER &&
      user.role !== USER_ROLES.ADMIN
    ) {
      throw new UnauthorizedError("Access denied");
    }

    // Update last login in local database
    await prisma.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() },
    });

    return {
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      points: user.points,
      firebaseUid: user.firebaseUid,
    };
  }

  // Login with Firebase token (mobile)
  async loginWithFirebase(firebaseToken) {
    try {
      // Verify Firebase token
      const decodedToken = await admin.auth().verifyIdToken(firebaseToken);
      const { uid, email, name } = decodedToken;

      // Find or create user
      let user = await prisma.user.findUnique({
        where: { firebaseUid: uid },
      });

      if (!user) {
        // Create new user from Firebase
        user = await prisma.user.create({
          data: {
            firebaseUid: uid,
            email,
            name: name || "User",
            role: USER_ROLES.CITIZEN,
            isActive: true,
            points: 0,
          },
        });
        console.log("✅ New user created from Firebase login:", user.email);
      }

      // Update last login
      await prisma.user.update({
        where: { id: user.id },
        data: { lastLoginAt: new Date() },
      });

      return {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
        points: user.points,
        firebaseUid: user.firebaseUid,
      };
    } catch (error) {
      console.error("Firebase login error:", error);
      throw new UnauthorizedError("Invalid Firebase token");
    }
  }

  // Update Firebase user profile
  async updateFirebaseProfile(firebaseUid, { displayName, email }) {
    try {
      const updateData = {};
      if (displayName) updateData.displayName = displayName;
      if (email) updateData.email = email;

      await admin.auth().updateUser(firebaseUid, updateData);
      console.log("✅ Firebase profile updated for UID:", firebaseUid);
      return true;
    } catch (error) {
      console.error("❌ Error updating Firebase profile:", error);
      throw error;
    }
  }

  // Delete Firebase user
  async deleteFirebaseUser(firebaseUid) {
    try {
      await admin.auth().deleteUser(firebaseUid);
      console.log("✅ Firebase user deleted:", firebaseUid);
      return true;
    } catch (error) {
      console.error("❌ Error deleting Firebase user:", error);
      throw error;
    }
  }

  // Get Firebase user info
  async getFirebaseUser(firebaseUid) {
    try {
      const userRecord = await admin.auth().getUser(firebaseUid);
      return {
        uid: userRecord.uid,
        email: userRecord.email,
        displayName: userRecord.displayName,
        emailVerified: userRecord.emailVerified,
        disabled: userRecord.disabled,
        metadata: {
          creationTime: userRecord.metadata.creationTime,
          lastSignInTime: userRecord.metadata.lastSignInTime,
        },
      };
    } catch (error) {
      console.error("❌ Error getting Firebase user:", error);
      return null;
    }
  }

  // Create session
  async createSession(userId, deviceInfo, ipAddress) {
    const refreshToken = uuidv4();
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 30); // 30 days

    const session = await prisma.userSession.create({
      data: {
        userId,
        token: uuidv4(),
        refreshToken,
        deviceInfo,
        ipAddress,
        expiresAt,
      },
    });

    return session;
  }

  // Get user by ID
  async getUserById(userId) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        name: true,
        phone: true,
        profilePicture: true,
        role: true,
        points: true,
        firebaseUid: true,
        createdAt: true,
        lastLoginAt: true,
      },
    });

    if (!user) {
      throw new UnauthorizedError("User not found");
    }

    return user;
  }

  // Refresh token
  async refreshToken(refreshToken) {
    const session = await prisma.userSession.findUnique({
      where: { refreshToken },
      include: { user: true },
    });

    if (!session || !session.isActive || session.expiresAt < new Date()) {
      throw new UnauthorizedError("Invalid refresh token");
    }

    // Generate new tokens
    const newToken = uuidv4();
    const newRefreshToken = uuidv4();

    await prisma.userSession.update({
      where: { id: session.id },
      data: {
        token: newToken,
        refreshToken: newRefreshToken,
      },
    });

    return {
      token: newToken,
      refreshToken: newRefreshToken,
      user: {
        id: session.user.id,
        email: session.user.email,
        name: session.user.name,
        role: session.user.role,
        firebaseUid: session.user.firebaseUid,
      },
    };
  }
}

module.exports = new AuthService();
