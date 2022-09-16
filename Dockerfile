## Dockerfile for manuscript building from Latex
FROM ubuntu:20.04 as builder
ARG dataDir=/data
ARG projectDir=/src
ARG binDir=/usr/local/bin
ARG manDir=/usr/local/man
ARG tmpDir=/tmp

## INSTALLS
RUN apt update --fix-missing && \
    DEBIAN_FRONTEND=noninteractive apt install -y wget unzip make && \
    apt -y auto-remove && \
    rm -rf /var/lib/apt/lists/*

## LATEX PACKAGES
WORKDIR $tmpDir

# latex expand: used to flatten tex files with "input" or "include" commands.
RUN wget https://mirrors.ctan.org/support/latexpand.zip
RUN unzip latexpand.zip 
RUN mv latexpand/latexpand $binDir

# latex diff: used to create difference document with additions and removals
RUN wget https://mirrors.ctan.org/support/latexdiff.zip 
RUN unzip latexdiff.zip
WORKDIR $tmpDir/latexdiff
RUN make install
WORKDIR $tmpDir

# texcount: used to count characters, words, etc
RUN wget https://mirrors.ctan.org/support/texcount.zip
RUN unzip texcount.zip
RUN mv texcount/texcount.pl $binDir

################################################################################
FROM ubuntu:20.04 as development

## INSTALLS
RUN apt update --fix-missing && \
    DEBIAN_FRONTEND=noninteractive apt install -y texlive-full perl-doc git && \
    apt -y auto-remove && \
    rm -rf /var/lib/apt/lists/*

## Copy over packages
COPY --from=builder $binDir $binDir
RUN chmod 774 $binDir/*

## ADDING USER GROUP ##
ARG id=1001
ARG name=user
#RUN addgroup --gid $GroupID $GroupName
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

