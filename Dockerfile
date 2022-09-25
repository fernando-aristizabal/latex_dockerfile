## Dockerfile for manuscript building from Latex
FROM ubuntu:22.04 as builder
ARG dataDir=/data
ARG projectDir=/src
ARG binDir=/usr/local/bin
ARG manDir=/usr/local/man
ARG tmpDir=/tmp

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

## SETTING ENV VARIABLES ##
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

## LABELS
LABEL version="" \
      maintaner="Fernando Aristizabal" \
      release-date=""

## INSTALLS
RUN apt update --fix-missing && \
    DEBIAN_FRONTEND=noninteractive apt install -qy texlive-full perl-doc git && \
    apt -y auto-remove && \
    rm -rf  /var/cache/apt/* /var/lib/apt/lists/*

## Copy over packages
COPY --from=builder $binDir $binDir

## ADDING USER GROUP ##
ARG id=1001
ARG name=user
RUN useradd -Ums /bin/bash -u $id $name
USER $name
WORKDIR /home/$name

## ADD TO PATHS ##
ENV PATH="$projectDir:${PATH}"

## RUN UMASK TO CHANGE DEFAULT PERMISSIONS ##
ADD ./entrypoint.sh /
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

################################################################################
FROM development as runtime

CMD $projectDir/Makefile

