FROM node:16.17.0-alpine AS builder

WORKDIR /app

COPY ./package.json ./
COPY ./yarn.lock ./
RUN yarn install

# ⚠️ Ensure .dockerignore excludes unnecessary/sensitive files
COPY . .

ARG TMDB_V3_API_KEY
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"

RUN yarn build

FROM nginx:stable-alpine

# Set working directory and clean default files
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*

# Copy built files from builder
COPY --from=builder /app/dist .

# ⚠️ Switch to non-root user for improved security
USER nginx

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
