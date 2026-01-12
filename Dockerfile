FROM node:18 AS build

WORKDIR /opt/node_app

COPY . .

# Install dependencies
RUN yarn --network-timeout 600000

ARG NODE_ENV=production

RUN yarn build:app:docker

FROM nginx:1.27-alpine

# Copy built files
COPY --from=build /opt/node_app/excalidraw-app/build /usr/share/nginx/html

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Railway uses PORT env variable - expose it
EXPOSE 80

# Use a simpler healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -q --spider http://localhost:80/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
