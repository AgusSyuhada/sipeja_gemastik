const authService = require("../../services/authService");
const { USER_ROLES } = require("../../utils/constants");

module.exports = async function (fastify, opts) {
  fastify.post(
    "/register",
    {
      schema: {
        body: {
          type: "object",
          required: ["email", "password", "name"],
          properties: {
            email: { type: "string", format: "email" },
            password: { type: "string", minLength: 6 },
            name: { type: "string", minLength: 2 },
            role: { type: "string", enum: ["STAKEHOLDER", "ADMIN"] },
          },
        },
      },
    },
    async (request, reply) => {
      const { email, password, name, role } = request.body;

      const user = await authService.register({
        email,
        password,
        name,
        role: role || USER_ROLES.STAKEHOLDER,
      });

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
        message: "Registration successful",
        data: {
          user,
          token,
          refreshToken: session.refreshToken,
        },
      };
    }
  );
};
