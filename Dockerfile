FROM ubuntu:26.04 AS builder

RUN apt-get update -qq
RUN apt-get install -y git libpq-dev libopencv-dev tesseract-ocr libvips42 build-essential wget libmagickwand-dev

RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.15.0
ENV PATH="$PATH:/root/.asdf/bin"
ENV PATH=$PATH:/root/.asdf/shims

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

RUN asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
WORKDIR /tmp
COPY .tool-versions.web /tmp/.tool-versions
RUN asdf install
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

# RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.15.0
# ENV PATH="$PATH:/root/.asdf/bin"
# ENV PATH=$PATH:/root/.asdf/shims


# ENV RAILS_ENV="production" \
#     BUNDLE_DEPLOYMENT="1" \
#     BUNDLE_PATH="/usr/local/bundle" \
#     BUNDLE_WITHOUT="development"

# RUN asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git

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



# RUN asdf install
# RUN bundle
# RUN chmod a+x bin/rails

# RUN npm install --global yarn
# RUN yarn

# RUN bundle exec bootsnap precompile app/ lib/
# RUN ./bin/rails shakapacker:compile --trace

# # COPY images '/dfg/images'

# EXPOSE 3000
# CMD ["./bin/rails", "server"]

