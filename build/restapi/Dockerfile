FROM node:21.5.0-bullseye

WORKDIR /

RUN mkdir /app

COPY src/dist /app
COPY src /app
COPY scripts /app

RUN cd /app && npm install

ENTRYPOINT [ "/app/start.sh"]