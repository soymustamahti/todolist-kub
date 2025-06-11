#!/bin/bash

# Script to update Kubernetes secrets with base64 encoded values
# Run this script after setting up your cluster

set -e

echo "🔐 Setting up Kubernetes secrets..."

# Generate JWT secret if not provided
JWT_SECRET=${JWT_SECRET:-$(openssl rand -base64 32)}

# Database configuration
POSTGRES_USER="todouser"
POSTGRES_PASSWORD="todopass123"
POSTGRES_DB="todoapp"
DATABASE_URL="postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres-service:5432/${POSTGRES_DB}?schema=public"

# Encode values to base64
DATABASE_URL_B64=$(echo -n "$DATABASE_URL" | base64 -w 0)
JWT_SECRET_B64=$(echo -n "$JWT_SECRET" | base64 -w 0)
POSTGRES_USER_B64=$(echo -n "$POSTGRES_USER" | base64 -w 0)
POSTGRES_PASSWORD_B64=$(echo -n "$POSTGRES_PASSWORD" | base64 -w 0)
POSTGRES_DB_B64=$(echo -n "$POSTGRES_DB" | base64 -w 0)

# Update secrets.yaml with actual values
sed -i "s/__DATABASE_URL_BASE64__/$DATABASE_URL_B64/g" k8s/secrets.yaml
sed -i "s/__JWT_SECRET_BASE64__/$JWT_SECRET_B64/g" k8s/secrets.yaml
sed -i "s/__POSTGRES_USER_BASE64__/$POSTGRES_USER_B64/g" k8s/secrets.yaml
sed -i "s/__POSTGRES_PASSWORD_BASE64__/$POSTGRES_PASSWORD_B64/g" k8s/secrets.yaml
sed -i "s/__POSTGRES_DB_BASE64__/$POSTGRES_DB_B64/g" k8s/secrets.yaml

echo "✅ Secrets updated in k8s/secrets.yaml"
echo ""
echo "📋 Save these values for GitHub secrets:"
echo "DATABASE_URL: $DATABASE_URL"
echo "JWT_SECRET: $JWT_SECRET"
echo "POSTGRES_USER: $POSTGRES_USER"
echo "POSTGRES_PASSWORD: $POSTGRES_PASSWORD"
echo "POSTGRES_DB: $POSTGRES_DB"
