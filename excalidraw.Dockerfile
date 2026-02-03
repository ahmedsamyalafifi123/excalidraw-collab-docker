FROM node:20-alpine AS build

RUN apk add --no-cache git

WORKDIR /app

# Define the arguments
ARG VITE_APP_WS_SERVER_URL
ARG CACHE_INVALIDATOR

# 1. Clone the repo
RUN git clone --depth 1 https://github.com/excalidraw/excalidraw.git .

# 2. FORCE the variable into the build (This is the fix!)
RUN echo "VITE_APP_WS_SERVER_URL=$VITE_APP_WS_SERVER_URL" > .env.local
RUN echo "Building with WS URL: $VITE_APP_WS_SERVER_URL"

RUN yarn --network-timeout 600000
RUN yarn build:app:docker

FROM nginx:1.27-alpine
COPY --from=build /app/excalidraw-app/build /usr/share/nginx/html
HEALTHCHECK CMD wget -q -O /dev/null http://localhost || exit 1
