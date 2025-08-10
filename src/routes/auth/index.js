module.exports = async function (fastify, opts) {
  fastify.register(require("./register"));
  fastify.register(require("./login"));
  fastify.register(require("./profile"));
  fastify.register(require("./refresh"));
};
