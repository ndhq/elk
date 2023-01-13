FROM node:lts-alpine AS base

# Prepare work directory
WORKDIR /elk

FROM base AS builder

# Prepare pnpm ( refer to https://pnpm.io/installation#on-alpine-linux )
RUN wget -qO /bin/pnpm "https://github.com/pnpm/pnpm/releases/latest/download/pnpm-linuxstatic-x64" && chmod +x /bin/pnpm

# Prepare deps
RUN apk update
RUN apk add git --no-cache

# Copy all files
COPY . ./

# Specify container only environment variables
ENV NUXT_STORAGE_FS_BASE='/elk/data'

# Build
RUN pnpm i
RUN pnpm build

FROM base AS runner

ENV NODE_ENV=production

COPY --from=builder /elk/.output ./.output

EXPOSE 5314/tcp

ENV PORT=5314

# Persistent storage data
VOLUME [ "/elk/data" ]

CMD ["node", ".output/server/index.mjs"]
