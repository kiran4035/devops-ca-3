FROM node:lts

WORKDIR /app

COPY package.json .

RUN yarn

COPY . .

EXPOSE 80

CMD node index.js