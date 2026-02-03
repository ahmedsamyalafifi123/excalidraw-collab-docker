# excalidraw.Dockerfile
# 1. Start with Node 20 (as we fixed before)
FROM node:20-alpine AS build

# 2. Install git (This is the missing step!)
RUN apk add --no-cache git

# 3. Now the rest of your file can run
WORKDIR /app

ARG CACHE_INVALIDATOR
ARG VITE_APP_WS_SERVER_URL=https://oss-collab.excalidraw.com
ENV VITE_APP_WS_SERVER_URL=$VITE_APP_WS_SERVER_URL
RUN echo "Building using: $VITE_APP_WS_SERVER_URL"
RUN echo "Cache invalidator: $CACHE_INVALIDATOR"

# Clone the Excalidraw repo directly
RUN git clone --depth 1 https://github.com/excalidraw/excalidraw.git .

RUN yarn --network-timeout 600000
RUN yarn build:app:docker

# Production image
FROM nginx:1.27-alpine
COPY --from=build /app/excalidraw-app/build /usr/share/nginx/html
HEALTHCHECK CMD wget -q -O /dev/null http://localhost || exit 1
