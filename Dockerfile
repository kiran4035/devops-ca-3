FROM node:lts

WORKDIR /app

RUN git clone https://github.com/kiran4035/GPT-3-by-Team-Educators .

RUN yarn build

RUN npm i -g serve

EXPOSE 3000

CMD yarn start