# LaTex Dockerfile
Dockerfile used for a LaTex environment.

## Build Instructions

To build your image, execute: 

```
docker build --build-arg id=`$id -u` --build-arg `$id -nu` \
--target <target_stage> -t <image_name>:<tag> <project_directory>
```
<project_directory> is a path to your LaTex source files, while <target_stage> represents the stage to target for compilation.
The two options are "development" or "runtime" where runtime just includes the Makefile as the entry command.
The development container should be targeted if a variety of utilities want to be used within the containers.

## Compile document

For iteractive use with a development container:

`docker run --rm -it -v <project_directory>:/src <image_name>:<tag>`

For non-iteractive use with a runtime container:

`docker run --rm -v <project_directory>:/src <image_name>:<tag> <your_make_file_arguments>`
