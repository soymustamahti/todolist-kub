# Build stage
FROM node:22-alpine AS builder

WORKDIR /app

# Copy root package.json and yarn.lock for workspace setup
COPY package.json yarn.lock ./

# Copy frontend package.json
COPY apps/frontend/package.json ./apps/frontend/

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy frontend source code
COPY apps/frontend/ ./apps/frontend/

# Change to frontend directory
WORKDIR /app/apps/frontend

# Build the application
RUN yarn build

# Production stage
FROM nginx:alpine

# Create directories with proper permissions and run as root
RUN mkdir -p /var/cache/nginx/client_temp /var/cache/nginx/proxy_temp \
    /var/cache/nginx/fastcgi_temp /var/cache/nginx/uwsgi_temp /var/cache/nginx/scgi_temp && \
    chmod -R 777 /var/cache/nginx && \
    chmod -R 777 /var/run

# Copy built app to nginx
COPY --from=builder /app/apps/frontend/dist /usr/share/nginx/html

# Copy nginx configuration
COPY apps/frontend/nginx.conf /etc/nginx/conf.d/default.conf

# Set proper permissions for web content
RUN chmod -R 755 /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
