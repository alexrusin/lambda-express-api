FROM node:18.14-alpine AS builder
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat
RUN apk update
# Set working directory
WORKDIR /app
COPY . .
RUN yarn install
RUN yarn build

FROM node:18.14-alpine AS installer
RUN apk add --no-cache libc6-compat
RUN apk update
WORKDIR /app
COPY --from=builder /app/package.json .
COPY --from=builder /app/yarn.lock .
RUN yarn install --production=true

FROM public.ecr.aws/lambda/nodejs:18 AS runner
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/lambda.js .
COPY --from=installer /app/node_modules ./node_modules

CMD [ "lambda.handler" ]