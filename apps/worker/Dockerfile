FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./
COPY apps/api/package*.json apps/api/
COPY apps/worker/package*.json apps/worker/
COPY packages/shared-types/package*.json packages/shared-types/
RUN npm ci

COPY . .
RUN npm run build --workspace apps/worker

FROM node:20-alpine AS runner
WORKDIR /app

COPY package*.json ./
COPY apps/api/package*.json apps/api/
COPY apps/worker/package*.json apps/worker/
COPY packages/shared-types/package*.json packages/shared-types/
RUN npm ci --omit=dev

COPY --from=builder /app/apps/worker/dist ./apps/worker/dist

EXPOSE 3010
CMD ["node", "apps/worker/dist/main.js"]
