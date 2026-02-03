FROM node:20-alpine AS build
RUN apk add --no-cache git
WORKDIR /app

# Clone the repo
RUN git clone --depth 1 https://github.com/excalidraw/excalidraw.git .

# Install dependencies
RUN yarn --network-timeout 600000

# CRITICAL: Set the env var BEFORE building
# Vite reads import.meta.env.VITE_APP_WS_SERVER_URL at build time
ARG VITE_APP_WS_SERVER_URL
ENV VITE_APP_WS_SERVER_URL=$VITE_APP_WS_SERVER_URL

# Debug: Show all VITE_ env vars
RUN env | grep VITE

# Create a .env file for Vite to read (belt and suspenders approach)
RUN echo "VITE_APP_WS_SERVER_URL=$VITE_APP_WS_SERVER_URL" > .env.production

# Show what's in the .env file
RUN cat .env.production

# Build the app
RUN yarn build:app:docker

# Verify the URL made it into the build
RUN echo "Checking if URL is in the build:" && \
    grep -r "excalidraw-room.zuwad-academy.com" /app/excalidraw-app/build/assets/ || \
    echo "WARNING: URL NOT FOUND IN BUILD FILES!"

# Production image
FROM nginx:1.27-alpine
COPY --from=build /app/excalidraw-app/build /usr/share/nginx/html
