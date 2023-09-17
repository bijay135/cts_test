FROM node:lts-alpine as build-stage

# Configures files, dependencies and build
WORKDIR /app
COPY vuejs/package*.json ./
RUN npm install
COPY vuejs/. .
RUN npm run build

FROM nginx:stable-alpine as deploy-stage

# Configure server and app artifacts
COPY --from=build-stage /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]