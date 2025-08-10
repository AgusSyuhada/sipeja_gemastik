const { authenticateToken } = require("../../middlewares/auth");

module.exports = async function (fastify, opts) {
  fastify.get(
    "/profile",
    {
      preHandler: [authenticateToken],
    },
    async (request, reply) => {
      return {
        success: true,
        data: {
          user: request.user,
        },
      };
    }
  );

  fastify.put(
    "/profile",
    {
      preHandler: [authenticateToken],
      schema: {
        body: {
          type: "object",
          properties: {
            name: { type: "string", minLength: 2 },
            phone: { type: "string" },
          },
        },
      },
    },
    async (request, reply) => {
      const { name, phone } = request.body;
      const userId = request.user.id;

      const updatedUser = await fastify.prisma.user.update({
        where: { id: userId },
        data: { name, phone },
        select: {
          id: true,
          email: true,
          name: true,
          phone: true,
          role: true,
          totalPoints: true,
        },
      });

      return {
        success: true,
        message: "Profile updated successfully",
        data: {
          user: updatedUser,
        },
      };
    }
  );
};
