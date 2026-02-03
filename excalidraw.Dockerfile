# excalidraw.Dockerfile
FROM node:20-alpine AS build
RUN apk add --no-cache git
WORKDIR /app

# Clone the repo
RUN git clone --depth 1 https://github.com/excalidraw/excalidraw.git .

# Install dependencies
RUN yarn --network-timeout 600000

# SET THE VARIABLES RIGHT BEFORE THE BUILD
ARG VITE_APP_WS_SERVER_URL
ARG CACHE_INVALIDATOR

# We force them into the environment so Vite picks them up
ENV VITE_APP_WS_SERVER_URL=$VITE_APP_WS_SERVER_URL
ENV VITE_APP_STORAGE_BACKEND=https

RUN echo "Building with WS: $VITE_APP_WS_SERVER_URL"

# Build the app
RUN yarn build:app:docker

# Production image
FROM nginx:1.27-alpine
COPY --from=build /app/excalidraw-app/build /usr/share/nginx/html
