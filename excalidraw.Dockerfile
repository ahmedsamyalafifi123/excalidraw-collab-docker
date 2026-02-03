# excalidraw.Dockerfile
FROM node:20-alpine AS build
RUN apk add --no-cache git
WORKDIR /app

# Clone the repo
RUN git clone --depth 1 https://github.com/excalidraw/excalidraw.git .

# Install dependencies
RUN yarn --network-timeout 600000

# THESE MUST BE DEFINED AS ARGS AND THEN ENV RIGHT BEFORE THE BUILD
ARG VITE_APP_WS_SERVER_URL
ENV VITE_APP_WS_SERVER_URL=$VITE_APP_WS_SERVER_URL

# Verify the variable is actually there during build
RUN echo "THE WS SERVER URL IS: $VITE_APP_WS_SERVER_URL"

# Build the app - Vite will now "bake" the URL into the JS files
RUN yarn build:app:docker

# Production image
FROM nginx:1.27-alpine
COPY --from=build /app/excalidraw-app/build /usr/share/nginx/html
