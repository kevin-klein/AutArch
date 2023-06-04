sudo apt install -y curl libgsl-dev libopencv-dev libvips-dev gnupg2 libjemalloc-dev

gpg2 --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable
source ~/.bashrc

rvm install 3.1.2 -C -with-jemalloc

sudo snap install inkscape
bundle

curl https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh > nvm_install.sh
bash nvm_install.sh
source ~/.bashrc
nvm install v18
npm install -g yarn
yarn

cd image_processing
ruby extconf.rb
make
