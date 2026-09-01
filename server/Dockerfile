FROM node:22-alpine

RUN apk add --no-cache chromium nss freetype harfbuzz ca-certificates ttf-freefont
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .
RUN mkdir -p /app/public/uploads /app/public/models /app/data
RUN cp -r /app/public /app/public-seed
RUN chmod +x /app/docker-entrypoint.sh
EXPOSE 3001
ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["node", "dist/start.js"]
