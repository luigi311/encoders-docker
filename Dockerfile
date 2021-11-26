FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ARG CFLAGS="-fno-omit-frame-pointer -pthread -fgraphite-identity -floop-block -ldl -lpthread -g -fPIC -I/usr/include/x86_64-linux-gnu"
ARG CXXFLAGS="-fno-omit-frame-pointer -pthread -fgraphite-identity -floop-block -ldl -lpthread -g -fPIC -I/usr/include/x86_64-linux-gnu"
ARG LDFLAGS="-Wl,-Bsymbolic -fPIC -L/usr/lib/x86_64-linux-gnu -static"
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib:/usr/local/lib/x86_64-linux-gnu/

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        jq \
        pkg-config \
        git \
        curl \
        wget \
        python3 \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        python3-docutils \
        openssl \
        xz-utils \
        vim \
        nano \
        libx265-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# Install libx265-dev until x265 can be built statically

# Install libvmaf
COPY --from=registry.gitlab.com/luigi311/encoders-docker/aomenc:static-latest /vmaf.deb /packages/
RUN dpkg -i /packages/vmaf.deb

# Install aomenc
COPY --from=registry.gitlab.com/luigi311/encoders-docker/aomenc:static-latest /aomenc.deb /packages/
RUN dpkg -i /packages/aomenc.deb

# Install svt-av1
COPY --from=registry.gitlab.com/luigi311/encoders-docker/svt-av1:static-latest /svt-av1.deb /packages/
RUN dpkg -i /packages/svt-av1.deb

# Install rav1e
COPY --from=registry.gitlab.com/luigi311/encoders-docker/rav1e:static-latest /rav1e-static/usr /usr
COPY --from=registry.gitlab.com/luigi311/encoders-docker/rav1e:static-latest /usr/local/bin/rav1e /usr/local/bin/rav1e

# Install x265
COPY --from=registry.gitlab.com/luigi311/encoders-docker/x265:static-latest /x265.deb /packages/
RUN dpkg -i /packages/x265.deb

# Install svt-hevc
COPY --from=registry.gitlab.com/luigi311/encoders-docker/svt-hevc:static-latest /svt-hevc.deb /packages/
RUN dpkg -i /packages/svt-hevc.deb

# Install x264
COPY --from=registry.gitlab.com/luigi311/encoders-docker/x264:static-latest /x264.deb /packages/
RUN dpkg -i /packages/x264.deb

# Install vpxenc
COPY --from=registry.gitlab.com/luigi311/encoders-docker/vpxenc:static-latest /vpxenc.deb /packages/
RUN dpkg -i /packages/vpxenc.deb

# Install ffmpeg
COPY --from=registry.gitlab.com/luigi311/encoders-docker/ffmpeg:static-latest /ffmpeg.deb /packages/
RUN dpkg -i /packages/ffmpeg.deb

# Install avisynth
COPY --from=registry.gitlab.com/luigi311/encoders-docker/tools:static-latest /avisynth.deb /packages/
RUN dpkg -i /packages/avisynth.deb

# Install vapoursynth
COPY --from=registry.gitlab.com/luigi311/encoders-docker/tools:static-latest /vapoursynth.deb /packages/
RUN dpkg -i /packages/vapoursynth.deb

# Install lsmash
COPY --from=registry.gitlab.com/luigi311/encoders-docker/tools:static-latest /lsmash.deb /packages/
RUN dpkg -i /packages/lsmash.deb

# Install lsmash-vapoursynth
COPY --from=registry.gitlab.com/luigi311/encoders-docker/tools:static-latest /lsmash-vapoursynth.deb /packages/
RUN dpkg -i /packages/lsmash-vapoursynth.deb

# Install lsmash-avisynth
COPY --from=registry.gitlab.com/luigi311/encoders-docker/tools:static-latest /lsmash-avisynth.deb /packages/
RUN dpkg -i /packages/lsmash-avisynth.deb

# Install ffms2
COPY --from=registry.gitlab.com/luigi311/encoders-docker/tools:static-latest /ffms2.deb /packages/
RUN dpkg -i /packages/ffms2.deb

# Install Johnvansickle FFMPEG
COPY ffmpeg-release-amd64-static.tar.xz /packages/ffmpeg-release-amd64-static.tar.xz
WORKDIR /packages
RUN tar -xf ffmpeg-* && \
    mv ffmpeg-*/* /usr/local/bin/

# Reset workdir to root
WORKDIR /
