#!/bin/sh
set -e

echo "🚀 Starting backend initialization..."

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
until npx prisma db push --accept-data-loss > /dev/null 2>&1; do
  echo "⏳ Database not ready yet, retrying in 5 seconds..."
  sleep 5
done

echo "✅ Database is ready!"

# Run database migrations
echo "🔄 Running database migrations..."
npx prisma migrate deploy

# Generate Prisma client (in case it's needed)
echo "🔧 Generating Prisma client..."
npx prisma generate

# Seed the database if needed (optional, uncomment if you want initial data)
# echo "🌱 Seeding database..."
# npm run seed

echo "🎉 Backend initialization complete!"

# Start the application
echo "🚀 Starting backend application..."
exec node dist/index.js
