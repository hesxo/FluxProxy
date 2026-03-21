# Use official Node.js Alpine image for a smaller footprint
FROM node:24-alpine

# Patch OS packages (e.g. zlib) when Alpine publishes fixes
RUN apk upgrade --no-cache

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci --omit=dev

COPY . .

RUN chown -R node:node /app
USER node

EXPOSE 3000

CMD ["node", "server.js"]
