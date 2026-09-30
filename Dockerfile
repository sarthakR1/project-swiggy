# ==========================================
# Stage 1: Build & Dependency Installation
# ==========================================
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package manifests first to leverage Docker layer caching
COPY package*.json ./

# Install dependencies (use npm ci for reproducible builds)
RUN npm ci

# Copy the rest of the application code
COPY . .

# Optional: Build step if you use frontend frameworks (React/Vue/Angular)
# RUN npm run build


# ==========================================
# Stage 2: Production Execution Environment
# ==========================================
FROM node:20-alpine AS runner

WORKDIR /app

# Set environment to production
ENV NODE_ENV=production

# Copy built app and node_modules from builder stage
COPY --from=builder /app ./

# Expose application port (adjust port if your app runs on a different port like 3000 or 8080)
EXPOSE 3000

# Security: Run as non-root node user provided by the alpine image
USER node

# Start the application
CMD ["npm", "start"]
