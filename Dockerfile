#Stage 1: Prepare
#Base for ReactJS App
FROM node:13 as builder
WORKDIR /usr/src/app
ENV NODE_ENV production
RUN npm i -g yarn
RUN npm i -g lerna
COPY ./lerna.json .
COPY ./package* ./
COPY ./yarn* ./
COPY ./.env .
COPY ./packages/shared/ ./packages/shared
COPY ./packages/api/ ./packages/api
#Installing Dependencies and Build Phase
RUN yarn install --production
RUN lerna bootstrap
RUN cd /usr/src/app/packages/shared && yarn build
RUN cd /usr/src/app/packages/api && yarn build

#Stage 2: Build Image
#Run IMAGE
FROM node:13
LABEL maintainer="angyay0"
LABEL version="1.0.0"
LABEL description="Docker Image Build"
RUN npm i -g yarn
RUN npm i -g lerna
ENV NODE_ENV production
ENV NPM_CONFIG_LOGLEVEL error
ARG PORT=3001
ENV PORT $PORT
WORKDIR /usr/src/app
COPY ./package* ./
COPY ./lerna.json ./
COPY ./.env ./
COPY ./yarn* ./
COPY --from=builder /usr/src/app/packages/shared ./packages/shared
COPY ./packages/api/package* ./packages/api/
COPY ./packages/api/.env* ./packages/api/
COPY --from=builder /usr/src/app/packages/api ./packages/api
RUN yarn install
CMD cd ./packages/api && yarn start-production
EXPOSE $PORT