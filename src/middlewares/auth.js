const { UnauthorizedError } = require("../utils/errors");
const authService = require("../services/authService");

const authenticateToken = async (request, reply) => {
  try {
    await request.jwtVerify();
    const user = await authService.getUserById(request.user.userId);
    request.user = user;
  } catch (error) {
    throw new UnauthorizedError("Invalid or expired token");
  }
};

const requireRole = (roles) => {
  return async (request, reply) => {
    if (!request.user) {
      throw new UnauthorizedError("Authentication required");
    }

    if (!roles.includes(request.user.role)) {
      throw new UnauthorizedError("Insufficient permissions");
    }
  };
};

module.exports = {
  authenticateToken,
  requireRole,
};
