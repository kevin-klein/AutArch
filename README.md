# AutArch

## Workflow

Publications can be imported under [Publications -> Import](http://localhost:3000/publications/new)

After the import has completed, the publication is available under [Publications](http://localhost:3000/publications). It is recommended to go to the [annotation screen](http://localhost:3000/publications/pages) and add all false negative objects.

To review all the graves, go to the [grave screen](http://localhost:3000/graves). Use the filter on the top to select the publications just uploaded. Then click the edit button of the first grave on the list.

#### Grave Data
The ID assigned to the burial by the authors in the source publication is recorded. In case multiple images of the same grave are shown, the software will prevent duplicates in the results using this ID. In this step, the expert also has the option to discard drawings incorrectly classified as a grave.


#### Site
Graves can be assigned to specific sites.

#### Tags
Graves can be given arbitrary tags to discern them and allow for filtering in the overview map.

#### Boxes
Correcting bounding boxes. The user can manually add, remove or change the bounding box assigned to a specific grave. Potential tasks include selecting a different scale on the page, resizing bounding boxes because they do not fully encapsulate an object or marking north arrows that were initially missed by object detection. During this step, a manual arrow has to be drawn for every skeleton following the spine and pointing towards the skull, which is necessary to determine the orientation of the skeleton in the grave. Several automated steps are then performed. The contours are calculated using the new bounding boxes and the resulting changes in measurements are saved. The orientation of the north arrow and the deposition type of the skeleton are updated using their respective neural network. The analysis of the scale is performed again.

#### Contours
All detected outlines in relation to one particular grave are highlighted, allowing the user, if any issue arises, to return to the previous step and fit, for instance, a manual bounding box around the grave or cross-section to indicate the width, length or depth.

#### Scale
The next step is to validate the scale by checking the text indicating the real-world length of the scale. Once this step is completed, all measurements are updated with the new scale information. In case no individual scale is provided and the publication uses a fixed scale, e.g. all drawings are 1:20, a different screen is shown. In this screen, the actual height of the page (in cm) has to be entered manually, together with the ratio of the drawing. This way, all measurements can be calculated in the absence of a scale and the results are fully compatible with scaled publications.

#### North Arrow
The angle of the north arrow can be adjusted manually based on a preview. In case an arrow is missing in the drawing, this screen will be skipped and size measurements and contours will still be collected without the orientation.


#### Skeleton Information
Finally, the pose of all skeletons has to be validated, which (for now) consists of “unknown”, “flexed on the side” or “supine”. As described above, a neural network will set the initial body position, but it can be adjusted manually. Further positions could easily be added in the future. “Unknown” is used in cases where skeletal remains are visible, but no position can be identified.

## Installation

This installation guide is intended for ubuntu linux. Windows systems are not natively supported but [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) is known to work. Installation procedure on other linux distributions will be similar.

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

## Training the models

To train the models yourself, download the "training_data" folder and put it inside the AutArch folder. To train the object detection network:

`$ python scripts/train_object_detection.py`

To train the skeleton deposition type classifier:

`$ python scripts/train_skeleton_classifier`

To train the arrow angle detection network:

`$ python scripts/train_arrow_angle_network.py`
