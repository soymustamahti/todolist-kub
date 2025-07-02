# Build stage
FROM node:22-alpine AS builder

WORKDIR /app

# Copy root package.json and yarn.lock for workspace setup
COPY package.json yarn.lock ./

# Copy backend package.json
COPY apps/backend/package.json ./apps/backend/

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy backend source code
COPY apps/backend/ ./apps/backend/

# Change to backend directory
WORKDIR /app/apps/backend

# Generate Prisma client
RUN yarn db:generate

# Build the application
RUN yarn build

# Production stage
FROM node:22-alpine

WORKDIR /app

# Install OpenSSL for Prisma compatibility
RUN apk add --no-cache openssl

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S backend -u 1001

# Copy root package.json and yarn.lock
COPY package.json yarn.lock ./

# Copy backend package.json
COPY apps/backend/package.json ./apps/backend/

# Install production dependencies only
RUN yarn install --frozen-lockfile --production && yarn cache clean

# Install Prisma CLI separately for migrations
RUN yarn add -W prisma@^5.7.0

# Copy built application and prisma from builder stage
COPY --from=builder --chown=backend:nodejs /app/apps/backend/dist ./dist
COPY --from=builder --chown=backend:nodejs /app/apps/backend/prisma ./prisma
COPY --from=builder --chown=backend:nodejs /app/node_modules/.prisma ./node_modules/.prisma

# Copy startup script
COPY --chown=backend:nodejs apps/backend/start.sh ./start.sh
RUN chmod +x ./start.sh

# Switch to non-root user
USER backend

EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3001/api/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

CMD ["./start.sh"]
