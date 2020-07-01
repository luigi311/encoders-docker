FROM ubuntu:18.04

# Set to noninteractive to fix issue with tzdate
ARG DEBIAN_FRONTEND=noninteractive

# Upgrade
RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    apt-add-repository multiverse && \
    apt-get install -y --no-install-recommends \
        git \
        time \
        cmake \
        gcc \
        g++ \
        make \
        nasm \
        yasm \
        parallel \
        ninja-build \
        doxygen \
        python3 \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        python3-docutils \
        curl \
        build-essential \ 
        checkinstall \
        bison \
        flex \
        gettext \
        mercurial \
        subversion \
        gyp \
        automake \ 
        pkg-config \ 
        libtool \
        libtool-bin \
        gcc-multilib \
        g++-multilib \
        libgmp-dev \
        libmpfr-dev \
        libmpc-dev \
        libgcrypt-dev \
        gperf \
        ragel \
        texinfo \
        autopoint \
        re2c \
        asciidoc  \
        rst2pdf \
        docbook2x \
        unzip \
        p7zip-full \
        doxygen \
        libsm6 \
        libxext6 \
        libxrender-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir meson

# Install libvmaf
RUN git clone https://github.com/Netflix/vmaf.git /tmp/vmaf
WORKDIR /tmp/vmaf/libvmaf
RUN meson build --buildtype release && \
    ninja -vC build || ninja -vC build && \
    ninja -vC build install

# Install FFMPEG
RUN curl -LO https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz && \
    tar xf ffmpeg-git-amd64-static.tar.xz && \
    mv ffmpeg-*/* /usr/local/bin/

# Install aomenc
RUN git clone https://aomedia.googlesource.com/aom /tmp/aomenc && \
    mkdir -p /tmp/aom_build
WORKDIR /tmp/aom_build
RUN cmake -DENABLE_SHARED=off -DENABLE_NASM=on -DCMAKE_BUILD_TYPE=Release -DCONFIG_TUNE_VMAF=1 /tmp/aomenc && \
    make -j"$(nproc)" && \
    make install

# Install svt-av1
RUN git clone https://github.com/OpenVisualCloud/SVT-AV1.git /tmp/svt-av1 && \
    mkdir -p /tmp/svt-av1/Build/linux/Release
WORKDIR /tmp/svt-av1/Build/linux/Release
RUN cmake -S /tmp/svt-av1/ -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF && \
    cmake --build . --target install

# Test Encoders
RUN aomenc --help && \
    SvtAv1EncApp --help