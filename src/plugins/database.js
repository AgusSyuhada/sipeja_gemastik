const fp = require("fastify-plugin");
const prisma = require("../config/database");

module.exports = fp(async function (fastify, opts) {
  fastify.decorate("prisma", prisma);

  fastify.addHook("onClose", async (instance) => {
    await instance.prisma.$disconnect();
  });
});
