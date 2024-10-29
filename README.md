# AutArch

## Workflow

Publications can be imported under [Publications -> Import](http://localhost:3000/publications/new)

After the import has completed, the publication is available under [Publications](http://localhost:3000/publications). It is recommended to go to the [annotation screen](http://localhost:3000/publications/pages) and add all false negative objects.

To review all the graves, go to the [grave screen](http://localhost:3000/graves). Use the filter on the top to select the publications just uploaded. Then click the edit button of the first grave on the list.

###

## Installation

This installation guide is intended for ubuntu linux. Windows systems are not supported. Installation procedure on other linux distributions will be similar.

AutArch requires the following packages:

`$ sudo apt install libpq-dev postgresql libopencv-dev tesseract-ocr redis-server libvips42 build-essential`

To manage the installations of ruby, python and nodejs asdf is recommended. Please refer to the [asdf guide](https://asdf-vm.com/guide/getting-started.html).

After installing asdf, install these asdf plugins:

### NodeJS
`$ asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git`

### Ruby
`$ asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git`

### Python
`$ asdf plugin-add python`

To install the necessary versions of the languages mentioned above:

```
$ cd AutArch
$ asdf install
```

To install ruby dependecies:

`$ bundle install `

Change your postgres password:

```
$ sudo su postgres -c psql
> alter user postgres with password '[your-password]'
```

Change the password in 'config/database.yml' for the development database settings to the one you chose.

Download the database dump front the provided link and load the dump into your copy of postgres:

```
$ bin/rails db:create

$ cat autarch_dump.gz | gunzip | psql -h localhost -U postgres comove_development
```

Extract the downloaded images to the storage folder:

`$ unzip /path/to/autarch_images.zip -d storage`

Install js dependencies:

`$ yarn`

To compile the C++ extensions:

```
$ cd image_processing
$ ruby extconf.rb
$ make
```

AutArch was tested with PyTorch 2.4.1. Other compatible versions may worka s well. For the best performance a GPU is highly recommended. Depending on the available memory some functionality related to ML models might be reduced. AutArch can be run without any ML models. In this case, all annotations have to be added manually but all existing data can be edited and viewed without the automated support.

To install Torch (depending on your system, please consult the [torch installation guide](https://pytorch.org/get-started/locally/)):

`$ pip install torch torchvision --index-url --index-url https://download.pytorch.org/whl/cu118`

`$ pip install numpy pillow bottle`

To copy the ML models:

`$ unzip /path/to/autarch_models.zip -d models`

## Running AutArch

You need to start three different components, the rails server, shakapacker and the python ml service.

To run shakapacker:

`$ bin/shakapacker-dev-server`

To run rails:

`$ bin/rails s`

To start the python ml service:

`$ python scripts/torch_service.py`

After all the services have successfully loaded, AutArch is accessible under [localhost:3000](http://localhost:3000)
