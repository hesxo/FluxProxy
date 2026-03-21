# Use official Node.js Alpine image for a smaller footprint
FROM node:24-alpine

# Set working directory
WORKDIR /app

# Install dependencies
COPY package.json package-lock.json* ./
RUN npm install

# Copy remaining app files
COPY . .

# Install nodemon globally for hot reloading
RUN npm install -g nodemon

# Expose the internal port
EXPOSE 3000

# Default command to run in dev mode using nodemon
CMD ["nodemon", "server.js"]
