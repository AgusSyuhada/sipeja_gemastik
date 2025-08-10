const app = require("./app");

const start = async () => {
  try {
    const address = await app.listen({
      port: process.env.PORT || 3000,
      host: process.env.HOST || "0.0.0.0",
    });

    app.log.info(`🚀 Server running on ${address}`);
    app.log.info(`📚 Health check: ${address}/health`);
  } catch (err) {
    app.log.error(err);
    process.exit(1);
  }
};

start();
