## Dockerfile for manuscript building from Latex
FROM ubuntu:22.04 as builder

## BUILD ARGS
ARG dataDir=/data \
    projectDir=/src \
    binDir=/usr/local/bin \
    manDir=/usr/local/man \
    tmpDir=/tmp

## INSTALLS
RUN apt update --fix-missing && \
    DEBIAN_FRONTEND=noninteractive apt install -qy wget unzip make && \
    apt -y auto-remove && \
    rm -rf  /var/cache/apt/* /var/lib/apt/lists/*

## LATEX PACKAGES
WORKDIR $tmpDir

# latex expand: used to flatten tex files with "input" or "include" commands.
RUN wget https://mirrors.ctan.org/support/latexpand.zip && \
    unzip latexpand.zip && \
    mv latexpand/latexpand $binDir

# latex diff: used to create difference document with additions and removals
RUN wget https://mirrors.ctan.org/support/latexdiff.zip && \
    unzip latexdiff.zip && \
    cd $tmpDir/latexdiff && \
    make install
WORKDIR $tmpDir

# texcount: used to count characters, words, etc
RUN wget https://mirrors.ctan.org/support/texcount.zip && \
    unzip texcount.zip && \
    mv texcount/texcount.pl $binDir

################################################################################
################################################################################
FROM ubuntu:22.04 as development

## BUILD ARGS
ARG ID=1001 \
    NAME=user \
    VERSION="" \
    MAINTANER="Fernando Aristizabal" \
    RELEASE_DATE=""

## SETTING ENV VARIABLES ##
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

## LABELS
LABEL VERSION=$VERSION \
      MAINTANER=$MAINTANER \
      RELEASE_DATE=$RELEASE_DATE

## INSTALLS
RUN apt update --fix-missing && \
    DEBIAN_FRONTEND=noninteractive apt install -qy texlive-full perl-doc git && \
    apt -y auto-remove && \
    rm -rf  /var/cache/apt/* /var/lib/apt/lists/*

## Copy over packages
COPY --from=builder $binDir $binDir

## ADDING USER GROUP ##
RUN useradd -Ums /bin/bash -u $ID $NAME
USER $NAME
WORKDIR /home/$NAME

## ADD TO PATHS ##
ENV PATH="$projectDir:${PATH}"

## RUN UMASK TO CHANGE DEFAULT PERMISSIONS ##
ADD ./entrypoint.sh /
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

################################################################################
FROM development as runtime

CMD $projectDir/Makefile

