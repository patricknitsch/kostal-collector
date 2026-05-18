FROM ruby:3.2-alpine AS builder
RUN apk add --no-cache build-base

WORKDIR /kostal-collector
COPY Gemfile* /kostal-collector/
RUN bundle config set path /usr/local/bundle && \
    bundle config set without 'development test' && \
    bundle install --jobs $(nproc) --retry 3 && \
    bundle clean --force

FROM ruby:3.2-alpine

RUN apk add --no-cache tzdata

ENV \
    MALLOC_ARENA_MAX=2 \
    RUBYOPT=--yjit

ARG BUILDTIME
ENV BUILDTIME=${BUILDTIME}

ARG VERSION
ENV VERSION=${VERSION}

ARG REVISION
ENV REVISION=${REVISION}

WORKDIR /kostal-collector

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY . /kostal-collector/

ENTRYPOINT ["bundle", "exec", "ruby", "app.rb"]
