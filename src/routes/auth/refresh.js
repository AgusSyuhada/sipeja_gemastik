const authService = require("../../services/authService");

module.exports = async function (fastify, opts) {
  fastify.post(
    "/refresh",
    {
      schema: {
        body: {
          type: "object",
          required: ["refreshToken"],
          properties: {
            refreshToken: { type: "string" },
          },
        },
      },
    },
    async (request, reply) => {
      const { refreshToken } = request.body;

      const result = await authService.refreshToken(refreshToken);

      // Generate new JWT
      const newJwtToken = fastify.jwt.sign({
        userId: result.user.id,
        email: result.user.email,
        role: result.user.role,
      });

      return {
        success: true,
        message: "Token refreshed successfully",
        data: {
          user: result.user,
          token: newJwtToken,
          refreshToken: result.refreshToken,
        },
      };
    }
  );
};
