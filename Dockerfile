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
        openssl \
        vim \
        nano && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y --default-toolchain nightly
ENV PATH="/root/.cargo/bin:$PATH"

# Install libvmaf
COPY --from=registry.gitlab.com/luigi311/encoders-docker/aomenc:latest /vmaf.deb /
RUN dpkg -i /vmaf.deb

# Install aomenc
COPY --from=registry.gitlab.com/luigi311/encoders-docker/aomenc:latest /aomenc.deb /
RUN dpkg -i /aomenc.deb

# Install svt-av1
COPY --from=registry.gitlab.com/luigi311/encoders-docker/svt-av1:latest /svt-av1.deb /
RUN dpkg -i /svt-av1.deb

# Install rav1e
COPY --from=registry.gitlab.com/luigi311/encoders-docker/rav1e:latest /rav1e-static/usr /usr
COPY --from=registry.gitlab.com/luigi311/encoders-docker/rav1e:latest /usr/local/bin/rav1e /usr/local/bin/rav1e

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

# Install ffmpeg
COPY --from=registry.gitlab.com/luigi311/encoders-docker/ffmpeg:latest /ffmpeg.deb /
RUN dpkg -i /ffmpeg.deb

# Install avisynth
COPY --from=registry.gitlab.com/luigi311/encoders-docker/tools:latest /avisynth.deb /
RUN dpkg -i /avisynth.deb

# Install vapoursynth
COPY --from=registry.gitlab.com/luigi311/encoders-docker/tools:latest /vapoursynth.deb /
RUN dpkg -i /vapoursynth.deb

# Install lsmash
COPY --from=registry.gitlab.com/luigi311/encoders-docker/tools:latest /lsmash.deb /
RUN dpkg -i /lsmash.deb

# Install lsmash-vapoursynth
COPY --from=registry.gitlab.com/luigi311/encoders-docker/tools:latest /lsmash-vapoursynth.deb /
RUN dpkg -i /lsmash-vapoursynth.deb

# Install lsmash-avisynth
COPY --from=registry.gitlab.com/luigi311/encoders-docker/tools:latest /lsmash-avisynth.deb /
RUN dpkg -i /lsmash-avisynth.deb

# Install ffms2
COPY --from=registry.gitlab.com/luigi311/encoders-docker/tools:latest /ffms2.deb /
RUN dpkg -i /ffms2.deb

# Reset workdir to root
WORKDIR /
