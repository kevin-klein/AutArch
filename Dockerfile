FROM ubuntu:26.04 AS builder

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y \
    git \
    libpq-dev \
    libopencv-dev \
    tesseract-ocr \
    libvips42 \
    build-essential \
    wget \
    libmagickwand-dev \
    curl \
    libffi-dev \
    ca-certificates \
    libyaml-dev

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV MISE_DATA_DIR="/mise"
ENV MISE_CONFIG_DIR="/mise"
ENV MISE_CACHE_DIR="/mise/cache"
ENV MISE_INSTALL_PATH="/usr/local/bin/mise"
ENV PATH="/mise/shims:$PATH"

RUN curl https://mise.run | sh

# Set up Node.js via mise (replaces asdf-nodejs)
WORKDIR /tmp
COPY .tool-versions /tmp/.tool-versions
RUN mise install

# Install yarn globally
RUN npm install -g yarn

FROM builder AS bundler
WORKDIR /tmp
RUN gem install bundler
COPY Gemfile /tmp/
COPY Gemfile.lock /tmp/
RUN bundle install

FROM node:18-bullseye-slim AS yarn
WORKDIR /tmp
COPY package.json .
COPY yarn.lock .
RUN yarn install

FROM builder as assets
WORKDIR /tmp
COPY --from=bundler /usr/local/bundle /usr/local/bundle
COPY --from=yarn /tmp/node_modules node_modules
COPY app/assets app/assets
COPY app/javascript app/javascript
COPY bin bin
COPY config config
COPY Rakefile Gemfile Gemfile.lock package.json yarn.lock /tmp/
RUN RAILS_ENV=production bundle exec rails shakapacker:compile

FROM builder as app
WORKDIR /dfg
COPY app '/dfg/app'
COPY assets '/dfg/assets'
COPY bin '/dfg/bin'
COPY config '/dfg/config'
COPY db '/dfg/db'
COPY lib '/dfg/lib'
COPY log '/dfg/log'
COPY public '/dfg/public'
COPY tmp '/dfg/tmp'
COPY vendor '/dfg/vendor'
COPY config.ru .
COPY Gemfile .
COPY Gemfile.lock .
COPY package.json .
COPY yarn.lock .
COPY Rakefile .

COPY --from=bundler /usr/local/bundle /usr/local/bundle
COPY --from=assets /tmp/public public

RUN chmod a+x bin/rails

EXPOSE 3000

CMD ["bin/rails", "server"]
