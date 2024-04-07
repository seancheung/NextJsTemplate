FROM node:lts AS builder-deps
WORKDIR /app
COPY package*.json ./
RUN npm install

FROM builder-deps AS builder
COPY src ./src
COPY prisma ./prisma
COPY *.json *.js *.mjs *.ts ./
ENV NEXT_TELEMETRY_DISABLED 1
RUN npx prisma generate
RUN npm run build

FROM node:lts AS runner-deps
WORKDIR /app
COPY package*.json ./
RUN npm install --production

FROM runner-deps AS runner
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules/.prisma/client ./node_modules/.prisma/client
COPY next.config.* ./
ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

EXPOSE 3000
ENV PORT 3000

CMD ["npm", "start"]