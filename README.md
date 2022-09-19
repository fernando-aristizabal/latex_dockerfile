# LaTex Dockerfile
Dockerfile used for a LaTex environment.

## Build Instructions

For a development image, execute: 

``docker build --build-arg id=`$id -u` --build-arg `$id -nu` --target development -t <image_name>:<tag> <project_directory>``

For a runtime image, execute: 

`docker build --target development -t <image_name>:<tag> <project_directory>`

<project_directory> is a path to your LaTex source files.

## Compile document

For iteractive use with a development container:

`docker run --rm -it -v <project_directory>:/src <image_name>:<tag>`

For non-iteractive use with a runtime container:

`docker run --rm -v <project_directory>:/src <image_name>:<tag> <your_make_file_arguments>`
