FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV CFLAGS="-fno-omit-frame-pointer -pthread -fgraphite-identity -floop-block -ldl -lpthread -g -fPIC -I/usr/include/x86_64-linux-gnu"
ENV CXXFLAGS="-fno-omit-frame-pointer -pthread -fgraphite-identity -floop-block -ldl -lpthread -g -fPIC -I/usr/include/x86_64-linux-gnu"
ENV LDFLAGS="-Wl,-Bsymbolic -fPIC -L/usr/lib/x86_64-linux-gnu -static"
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
        nano && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y --default-toolchain nightly
ENV PATH="/root/.cargo/bin:$PATH"

# Install libvmaf
COPY --from=registry.gitlab.com/luigi311/encoders-docker/aomenc:latest /vmaf.deb /packages/
#COPY --from=aomenc /vmaf.deb /packages/
RUN dpkg -i /packages/vmaf.deb

# Install aomenc
COPY --from=registry.gitlab.com/luigi311/encoders-docker/aomenc:latest /aomenc.deb /packages/
#COPY --from=aomenc /aomenc.deb /packages/
RUN dpkg -i /packages/aomenc.deb

# Install svt-av1
COPY --from=registry.gitlab.com/luigi311/encoders-docker/svt-av1:latest /svt-av1.deb /packages/
#COPY --from=svt-av1 /svt-av1.deb /packages/
RUN dpkg -i /packages/svt-av1.deb

# Install rav1e
COPY --from=registry.gitlab.com/luigi311/encoders-docker/rav1e:latest /rav1e-static/usr /usr
COPY --from=registry.gitlab.com/luigi311/encoders-docker/rav1e:latest /usr/local/bin/rav1e /usr/local/bin/rav1e
#COPY --from=rav1e /rav1e-static /
#wCOPY --from=rav1e /usr/local/bin/rav1e /usr/local/bin/rav1e

# Install x265
COPY --from=registry.gitlab.com/luigi311/encoders-docker/x265:latest /x265.deb /packages/
#COPY --from=x265 /x265.deb /packages/
RUN dpkg -i /packages/x265.deb

# Install svt-hevc
COPY --from=registry.gitlab.com/luigi311/encoders-docker/svt-hevc:latest /svt-hevc.deb /packages/
#COPY --from=svt-hevc /svt-hevc.deb /packages/
RUN dpkg -i /packages/svt-hevc.deb

# Install x264
COPY --from=registry.gitlab.com/luigi311/encoders-docker/x264:latest /x264.deb /packages/
#COPY --from=x264 /x264.deb /packages/
RUN dpkg -i /packages/x264.deb

# Install vpxenc
COPY --from=registry.gitlab.com/luigi311/encoders-docker/vpxenc:latest /vpxenc.deb /packages/
#COPY --from=vpxenc /vpxenc.deb /packages/
RUN dpkg -i /packages/vpxenc.deb

# Install ffmpeg
COPY --from=registry.gitlab.com/luigi311/encoders-docker/ffmpeg:latest /ffmpeg.deb /packages/
#COPY --from=ffmpeg /ffmpeg.deb /packages/
RUN dpkg -i /packages/ffmpeg.deb

# Install avisynth
COPY --from=registry.gitlab.com/luigi311/encoders-docker/tools:latest /avisynth.deb /packages/
#COPY --from=tools /avisynth.deb /packages/
RUN dpkg -i /packages/avisynth.deb

# Install vapoursynth
COPY --from=registry.gitlab.com/luigi311/encoders-docker/tools:latest /vapoursynth.deb /packages/
#COPY --from=tools /vapoursynth.deb /packages/
RUN dpkg -i /packages/vapoursynth.deb

# Install lsmash
COPY --from=registry.gitlab.com/luigi311/encoders-docker/tools:latest /lsmash.deb /packages/
#COPY --from=tools /lsmash.deb /packages/
RUN dpkg -i /packages/lsmash.deb

# Install lsmash-vapoursynth
COPY --from=registry.gitlab.com/luigi311/encoders-docker/tools:latest /lsmash-vapoursynth.deb /packages/
#COPY --from=tools /lsmash-vapoursynth.deb /packages/
RUN dpkg -i /packages/lsmash-vapoursynth.deb

# Install lsmash-avisynth
COPY --from=registry.gitlab.com/luigi311/encoders-docker/tools:latest /lsmash-avisynth.deb /packages/
#COPY --from=tools /lsmash-avisynth.deb /packages/
RUN dpkg -i /packages/lsmash-avisynth.deb

# Install ffms2
COPY --from=registry.gitlab.com/luigi311/encoders-docker/tools:latest /ffms2.deb /packages/
#COPY --from=tools /ffms2.deb /packages/
RUN dpkg -i /packages/ffms2.deb

# Install Johnvansickle FFMPEG
COPY ffmpeg-release-amd64-static.tar.xz /packages/ffmpeg-release-amd64-static.tar.xz
WORKDIR /packages
RUN tar -xf ffmpeg-* && \
    mv ffmpeg-*/* /usr/local/bin/

# Reset workdir to root
WORKDIR /
