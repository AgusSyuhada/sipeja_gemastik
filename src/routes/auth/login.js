const authService = require("../../services/authService");

module.exports = async function (fastify, opts) {
  // Web login with email/password
  fastify.post(
    "/login",
    {
      schema: {
        body: {
          type: "object",
          required: ["email", "password"],
          properties: {
            email: { type: "string", format: "email" },
            password: { type: "string" },
          },
        },
      },
    },
    async (request, reply) => {
      const { email, password } = request.body;

      const user = await authService.loginWithPassword({ email, password });

      // Generate JWT token
      const token = fastify.jwt.sign({
        userId: user.id,
        email: user.email,
        role: user.role,
      });

      // Create session
      const session = await authService.createSession(
        user.id,
        request.headers["user-agent"],
        request.ip
      );

      return {
        success: true,
        message: "Login successful",
        data: {
          user,
          token,
          refreshToken: session.refreshToken,
        },
      };
    }
  );

  // Mobile login with Firebase token
  fastify.post(
    "/login/firebase",
    {
      schema: {
        body: {
          type: "object",
          required: ["firebaseToken"],
          properties: {
            firebaseToken: { type: "string" },
          },
        },
      },
    },
    async (request, reply) => {
      const { firebaseToken } = request.body;

      const user = await authService.loginWithFirebase(firebaseToken);

      // Generate JWT token
      const token = fastify.jwt.sign({
        userId: user.id,
        email: user.email,
        role: user.role,
      });

      // Create session
      const session = await authService.createSession(
        user.id,
        request.headers["user-agent"],
        request.ip
      );

      return {
        success: true,
        message: "Firebase login successful",
        data: {
          user,
          token,
          refreshToken: session.refreshToken,
        },
      };
    }
  );
};
