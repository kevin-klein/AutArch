FROM ubuntu:latest

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y git libpq-dev postgresql libopencv-dev tesseract-ocr redis-server libvips42 build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget libbz2-dev

RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git ~/.asdf
ENV PATH="$PATH:/root/.asdf/bin"
ENV PATH=$PATH:/root/.asdf/shims

RUN asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
RUN asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
RUN asdf plugin-add python

ADD deployment-keys/id_rsa /root/.ssh/id_rsa
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
RUN git clone git@github.com:kevin-klein/dfg.git
WORKDIR /dfg

RUN asdf install
RUN bundle
RUN chmod a+x bin/rails
RUN bin/rails db:create

RUN npm install --global yarn
RUN yarn

RUN pip install poetry
RUN poetry install
