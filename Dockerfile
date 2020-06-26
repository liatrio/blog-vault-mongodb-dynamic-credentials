FROM node:12.16.3-alpine

WORKDIR /usr/src/app

COPY package.json yarn.lock ./
RUN yarn --production

COPY . .

ENTRYPOINT ["node", "src/index.js"]
