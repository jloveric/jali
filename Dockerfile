# Check http://releases.llvm.org/download.html#8.0.0 for the latest available binaries
FROM ubuntu:18.04

# Make sure the image is updated, install some prerequisites,
# Download the latest version of Clang (official binary) for Ubuntu
# Extract the archive and add Clang to the PATH
RUN apt-get update && apt-get install -y \
  xz-utils \
  build-essential \
  libboost-all-dev \
  vim \
  cmake \
  gfortran \
  git

RUN apt-get update && apt-get install -y liblapack-dev libblas-dev libhdf5-mpich-dev
RUN apt-get update && apt-get install -y libptscotch-dev
RUN apt-get update && apt-get install -y trilinos-all-dev
RUN apt-get update && apt-get install -y libnetcdf-dev
RUN apt-get update && apt-get install -y libexodusii-dev

WORKDIR app
COPY . .
COPY src src
COPY config config
COPY examples examples
COPY tools tools

RUN ./install.sh
RUN /bin/sh