async function logoutRoutes(fastify) {
  fastify.post(
    "/logout",
    {
      preHandler: [fastify.authenticate],
      schema: {
        tags: ["Authentication"],
        summary: "Logout user",
        description: "Logout user (client should delete tokens)",
        security: [{ bearerAuth: [] }],
        response: {
          200: {
            type: "object",
            properties: {
              success: { type: "boolean" },
              message: { type: "string" },
            },
          },
        },
      },
    },
    async (request, reply) => {
      fastify.log.info(`User logged out: ${request.user.email}`);
      return reply.send({ success: true, message: "Logged out successfully" });
    }
  );

  fastify.post(
    "/logout-all",
    {
      preHandler: [fastify.authenticate],
      schema: {
        tags: ["Authentication"],
        summary: "Logout from all devices",
        description: "Increment tokenVersion to invalidate all existing tokens",
        security: [{ bearerAuth: [] }],
        response: {
          200: {
            type: "object",
            properties: {
              success: { type: "boolean" },
              message: { type: "string" },
            },
          },
        },
      },
    },
    async (request, reply) => {
      try {
        await fastify.prisma.user.update({
          where: { id: request.user.id },
          data: { tokenVersion: { increment: 1 } },
        });

        fastify.log.info(
          `User logged out from all devices: ${request.user.email}`
        );
        return reply.send({
          success: true,
          message: "Logged out from all devices successfully",
        });
      } catch (error) {
        fastify.log.error(`Logout all failed: ${error.message}`);
        throw error;
      }
    }
  );
}

module.exports = logoutRoutes;
