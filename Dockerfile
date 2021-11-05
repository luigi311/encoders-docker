FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ARG CFLAGS="-fno-omit-frame-pointer -pthread -fgraphite-identity -floop-block -ldl -lpthread -g -fPIC"
ARG CXXFLAGS="-fno-omit-frame-pointer -pthread -fgraphite-identity -floop-block -ldl -lpthread -g -fPIC"
ARG LDFLAGS="-Wl,-Bsymbolic -fPIC"
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib:/usr/local/lib/x86_64-linux-gnu/

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        jq \
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
        libssl-dev \
        doxygen \
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
        libdevil-dev \
        libx265-dev \
        libnuma-dev \
        vim \
        nano && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir meson cython sphinx

# Install libvmaf
COPY --from=registry.gitlab.com/luigi311/encoders-docker/aomenc:latest /vmaf.deb /
RUN dpkg -i /vmaf.deb

# Install aomenc
COPY --from=registry.gitlab.com/luigi311/encoders-docker/aomenc:latest /aomenc.deb /
RUN dpkg -i /aomenc.deb

# Install svt-av1
COPY --from=registry.gitlab.com/luigi311/encoders-docker/svt-av1:latest /svt-av1.deb /
RUN dpkg -i /svt-av1.deb

# Install Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y --default-toolchain nightly
ENV PATH="/root/.cargo/bin:$PATH"

# Install rav1e
COPY --from=registry.gitlab.com/luigi311/encoders-docker/rav1e:latest /rav1e /rav1e
WORKDIR /rav1e
RUN cargo install cargo-c && \
    cargo cinstall --library-type=staticlib --crt-static --release --prefix=/usr/local

# Install x265
COPY --from=registry.gitlab.com/luigi311/encoders-docker/x265:latest /x265.deb /
RUN dpkg -i /x265.deb

# Install svt-hevc
COPY --from=registry.gitlab.com/luigi311/encoders-docker/svt-hevc:latest /svt-hevc.deb /
RUN dpkg -i /svt-hevc.deb

# Install x264
COPY --from=registry.gitlab.com/luigi311/encoders-docker/x264:latest /x264.deb /
RUN dpkg -i /x264.deb

# Install vpxenc
COPY --from=registry.gitlab.com/luigi311/encoders-docker/vpxenc:latest /vpxenc.deb /
RUN dpkg -i /vpxenc.deb

# Build avisynth
RUN git clone https://github.com/AviSynth/AviSynthPlus.git /AviSynthPlus && mkdir -p /AviSynthPlus/avisynth-build
WORKDIR /AviSynthPlus/avisynth-build
RUN cmake -S .. -DCMAKE_BUILD_TYPE:STRING='None' -Wno-dev && \
    make -j"$(nproc)" && \
    make install

# Install ffmpeg
COPY --from=registry.gitlab.com/luigi311/encoders-docker/ffmpeg:latest /ffmpeg.deb /
RUN dpkg -i /ffmpeg.deb

# Install vapoursynth dependencies
RUN mkdir -p /vapoursynth/dependencies && git clone https://github.com/sekrit-twc/zimg -b master --depth=1 /vapoursynth/dependencies/zimg
WORKDIR /vapoursynth/dependencies/zimg
RUN ./autogen.sh  && \
    ./configure --enable-static --disable-shared && \
    make -j"$(nproc)" && \
    make install

# Install Vapoursynth
# Pin to 54 as 55+ breaks lsmash
RUN git clone --branch R54 https://github.com/vapoursynth/vapoursynth.git /vapoursynth/build
WORKDIR /vapoursynth/build
RUN ./autogen.sh && \
    ./configure --enable-static --disable-shared && \
    make -j"$(nproc)" && \
    make install

RUN pip3 install VapourSynth

# Install ffms2
RUN git clone https://github.com/FFMS/ffms2.git /ffms2 && mkdir -p /ffms2/src/config
WORKDIR /ffms2/
RUN autoreconf -fiv && \
    ./configure --enable-static --disable-shared  && \
    make -j"$(nproc)" && \
    make install && \
    ln -s /ffms2/src/core/.libs/libffms2.so /usr/local/lib/vapoursynth

# Install lsmash
RUN git clone https://github.com/l-smash/l-smash /lsmash
WORKDIR /lsmash
RUN ./configure && \
    make -j"$(nproc)" && \
    make install
RUN echo "test"
RUN git clone https://github.com/luigi311/L-SMASH-Works /lsmash-plugin && mkdir -p /lsmash-plugin/build-vapoursynth /lsmash-plugin/build-avisynth
WORKDIR /lsmash-plugin/build-vapoursynth
RUN meson "../VapourSynth" --default-library static && \
    ninja && \
    ninja install

WORKDIR /lsmash-plugin/build-avisynth
RUN meson "../AviSynth" --default-library static && \
    ninja && \
    ninja install

# Reset workdir to root
WORKDIR /
