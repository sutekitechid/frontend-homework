FROM node:22-alpine AS build

WORKDIR /app

COPY package.json package-lock.json ./
COPY apps/spmi/package.json ./apps/spmi/package.json

RUN npm ci

COPY . .

RUN npm run build

FROM node:22-alpine AS production

WORKDIR /app

ENV NODE_ENV=production
ENV NITRO_HOST=0.0.0.0
ENV NITRO_PORT=3000

COPY --from=build /app/apps/spmi/.output ./.output

EXPOSE 3000

CMD ["node", ".output/server/index.mjs"]
