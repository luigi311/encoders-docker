FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ARG CFLAGS="-fno-omit-frame-pointer -pthread -fgraphite-identity -floop-block -ldl -lpthread -g -fPIC"
ARG CXXFLAGS="-fno-omit-frame-pointer -pthread -fgraphite-identity -floop-block -ldl -lpthread -g -fPIC"
ARG LDFLAGS="-Wl,-Bsymbolic -fPIC"
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib:/usr/local/lib/x86_64-linux-gnu/

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        pkg-config \
        git \
        curl \
        python3 \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        python3-docutils \
        build-essential \
        nasm \
        ninja-build \
        libnuma1 \
        libgl1-mesa-glx \
        cmake \
        libass-dev \
        autoconf \
        openssl \
        automake \
        libtool \
        libevent-dev \
        libjpeg-dev \
        libgif-dev \
        libpng-dev \
        libwebp-dev \
        libmemcached-dev \
        imagemagick \
        libpython3-dev \
        libavformat-dev \
        libavcodec-dev \
        libswscale-dev \
        libavutil-dev \
        libswresample-dev \
        libdevil-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir meson cython sphinx

# Install avisynth
COPY --from=registry.gitlab.com/luigi311/encoders-docker/ffmpeg:latest /AviSynthPlus /AviSynthPlus
WORKDIR /AviSynthPlus/avisynth-build
RUN make install

# Install ffmpeg
COPY --from=registry.gitlab.com/luigi311/encoders-docker/ffmpeg:latest /ffmpeg /ffmpeg
WORKDIR /ffmpeg
RUN make install

# Install vapoursynth
COPY --from=registry.gitlab.com/luigi311/encoders-docker/ffmpeg:latest /vapoursynth /vapoursynth
WORKDIR /vapoursynth/dependencies/zimg
RUN make install

WORKDIR /vapoursynth/build
RUN make install

RUN pip3 install VapourSynth

# Install ffms2
COPY --from=registry.gitlab.com/luigi311/encoders-docker/ffmpeg:latest /ffms2 /ffms2
WORKDIR /ffms2/
RUN make install && \
    ln -s /ffms2/src/core/.libs/libffms2.so /usr/local/lib/vapoursynth

# Install lsmash
COPY --from=registry.gitlab.com/luigi311/encoders-docker/ffmpeg:latest /lsmash /lsmash
WORKDIR /lsmash
RUN make install

COPY --from=registry.gitlab.com/luigi311/encoders-docker/ffmpeg:latest /lsmash-plugin /lsmash-plugin
WORKDIR /lsmash-plugin/build-vapoursynth
RUN ninja install

WORKDIR /lsmash-plugin/build-avisynth
RUN ninja install

# Install Johnvansickle FFMPEG
WORKDIR /
RUN curl -LO https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz && \
    tar xf ffmpeg-* && \
    mv ffmpeg-*/* /usr/local/bin/

# Install libvmaf
COPY --from=registry.gitlab.com/luigi311/encoders-docker/aomenc:latest /vmaf /vmaf
WORKDIR /vmaf/libvmaf
RUN ninja -vC build install

# Install aomenc
COPY --from=registry.gitlab.com/luigi311/encoders-docker/aomenc:latest /usr/local/bin/aomenc /usr/local/bin

# Install svt-av1
COPY --from=registry.gitlab.com/luigi311/encoders-docker/svt-av1:latest /usr/local/bin/SvtAv1EncApp /usr/local/bin

# Install rav1e
COPY --from=registry.gitlab.com/luigi311/encoders-docker/rav1e:latest /usr/local/bin/rav1e /usr/local/bin

# Install x265
COPY --from=registry.gitlab.com/luigi311/encoders-docker/x265:latest /usr/local/bin/x265 /usr/local/bin
COPY --from=registry.gitlab.com/luigi311/encoders-docker/x265:latest /usr/local/lib/libx265.a /usr/local/lib

# Install svt-hevc
COPY --from=registry.gitlab.com/luigi311/encoders-docker/svt-hevc:latest /usr/local/bin/SvtHevcEncApp /usr/local/bin

# Install x264
COPY --from=registry.gitlab.com/luigi311/encoders-docker/x264:latest /usr/local/bin/x264 /usr/local/bin

# Install vpxenc
COPY --from=registry.gitlab.com/luigi311/encoders-docker/vpxenc:latest /usr/local/bin/vpxenc /usr/local/bin

# Reset workdir to root
WORKDIR /
