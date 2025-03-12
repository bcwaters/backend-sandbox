# Extend base Dockerfile
FROM base.Dockerfile

# Override environment variables
ENV SERVICE_NAME=user-service
ENV PORT=3002

# Override exposed port
EXPOSE ${PORT}

# Override health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -qO- http://localhost:${PORT}/health || exit 1

# Override start command to use specific service entry point
CMD ["node", "dist/services/user-service/main"] 