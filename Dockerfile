FROM node:18
WORKDIR /srv/app
COPY ./app/package*.json ./
RUN npm install