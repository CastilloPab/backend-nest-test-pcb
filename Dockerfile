FROM node:22-alpine AS build

WORKDIR /usr/app

COPY ./dist ./dist
COPY ./package*.json ./
RUN npm install --only=production


EXPOSE 4000

CMD ["node", "dist/main.js"]
