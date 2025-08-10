require("dotenv").config();
const fastify = require("fastify");

const app = fastify({
  logger: {
    level: process.env.NODE_ENV === "production" ? "info" : "debug",
  },
});

// Register plugins
app.register(require("@fastify/cors"), {
  origin: true,
});
app.register(require("@fastify/helmet"));
app.register(require("@fastify/sensible"));
app.register(require("./plugins/database"));
app.register(require("./plugins/auth"));

// Register routes
app.register(require("./routes/auth/index"), { prefix: "/api/v1/auth" });

// Health check
app.get("/health", async (request, reply) => {
  return {
    status: "ok",
    timestamp: new Date().toISOString(),
    version: "1.0.0",
  };
});

// Global error handler
app.setErrorHandler(async (error, request, reply) => {
  request.log.error(error);

  // Custom app errors
  if (error.statusCode) {
    return reply.code(error.statusCode).send({
      success: false,
      error: error.name || "Error",
      message: error.message,
    });
  }

  // Prisma errors
  if (error.code === "P2002") {
    return reply.code(409).send({
      success: false,
      error: "Conflict",
      message: "Resource already exists",
    });
  }

  // Validation errors
  if (error.validation) {
    return reply.code(400).send({
      success: false,
      error: "Validation Error",
      message: error.message,
      details: error.validation,
    });
  }

  // Default error
  reply.code(500).send({
    success: false,
    error: "Internal Server Error",
    message: "Something went wrong",
  });
});

module.exports = app;
