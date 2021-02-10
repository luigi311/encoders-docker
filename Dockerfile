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

# Build avisynth
RUN git clone https://github.com/AviSynth/AviSynthPlus.git /AviSynthPlus && mkdir -p /AviSynthPlus/avisynth-build
WORKDIR /AviSynthPlus/avisynth-build
RUN cmake -S .. -DCMAKE_BUILD_TYPE:STRING='None' -Wno-dev && \
    make -j"$(nproc)" && \
    make install

# Install ffmpeg
COPY --from=registry.gitlab.com/luigi311/encoders-docker/ffmpeg:latest /ffmpeg /ffmpeg
WORKDIR /ffmpeg
RUN make install

# Build vapoursynth
RUN mkdir -p /vapoursynth/dependencies && git clone https://github.com/sekrit-twc/zimg -b master --depth=1 /vapoursynth/dependencies/zimg
WORKDIR /vapoursynth/dependencies/zimg
RUN ./autogen.sh  && \
    ./configure --enable-x86simd --disable-static --enable-shared && \
    make -j"$(nproc)" && \
    make install

RUN git clone https://github.com/vapoursynth/vapoursynth.git /vapoursynth/build
WORKDIR /vapoursynth/build
RUN ./autogen.sh && \
    ./configure --enable-shared && \
    make -j"$(nproc)" && \
    make install

RUN pip3 install VapourSynth

# Install ffms2
RUN git clone https://github.com/FFMS/ffms2.git /ffms2 && mkdir -p /ffms2/src/config
WORKDIR /ffms2/
RUN autoreconf -fiv && \
    ./configure --enable-shared  && \
    make -j"$(nproc)" && \
    make install && \
    ln -s /ffms2/src/core/.libs/libffms2.so /usr/local/lib/vapoursynth

# Install lsmash
RUN git clone https://github.com/l-smash/l-smash /lsmash
WORKDIR /lsmash
RUN ./configure --enable-shared && \
    make -j"$(nproc)" && \
    make install

RUN git clone https://github.com/HolyWu/L-SMASH-Works.git /lsmash-plugin && mkdir -p /lsmash-plugin/build-vapoursynth /lsmash-plugin/build-avisynth
WORKDIR /lsmash-plugin/build-vapoursynth
RUN meson "../VapourSynth" && \
    ninja && \
    ninja install

WORKDIR /lsmash-plugin/build-avisynth
RUN meson "../AviSynth" && \
    ninja

# Install Johnvansickle FFMPEG
WORKDIR /
RUN curl -LO https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz && \
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
