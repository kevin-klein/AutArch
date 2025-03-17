Autarch with complete data

Dependencies:
- docker
- unzip (or any other tool that can unzip a file, like 7z)

first download all zip files (dfg.zip.001, dfg.zip.002, ...) and extract:

eg:
$ cat dfg.zip.* > dfg.zip
$ unzip dfg.zip

To run:
$ cd dfg
$ docker compose --progress plain build
$ docker compose up

In case there are errors related to resolution of domains or network timeouts, please check your network connection and retry.

Please wait for the database to load the initial dump. It will indicate that it restarts after the dump has been loaded.
Initial requests can have a higher latency.

To train the models:

object detection:

$ cd dfg
$ docker build -f train-object-detection.Dockerfile -t 'autarch-object-detection' .
$ docker run --gpus all --rm -it --mount src="$(pwd)/models-new",target="/workspace/models",type=bind --shm-size 8192m autarch-object-detection

Please note that

supplementary
remove public/static
remove public/arrow.png
cleanup scripts / remove images
grave orientation to illustrations
cleanup jpgs in root folder
remove r script

clustering

Figure 1

$ docker build . -t autarch-figure-1
$ docker run --rm -it --mount src="$(pwd)/output",target="/workspace/output",type=bind autarch-figure-1

Table 1

$ docker build . -t autarch-table-1
$ docker run --rm -it autarch-table-1

Figure 2

$ docker build . -t autarch-figure-2
$ docker run --rm -it --mount src="$(pwd)/output",target="/output",type=bind autarch-figure-2

Figure 6

$ docker build . -t autarch-figure-6
$ docker run --rm -it --mount src="$(pwd)/output",target="/output",type=bind autarch-figure-6

Figure 7
$ docker build . -t autarch-figure-7
$ docker run --rm -it --mount src="$(pwd)/output",target="/output",type=bind autarch-figure-7
