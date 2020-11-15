FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/x86_64-linux-gnu/

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
        libgl1-mesa-glx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir meson

# Install FFMPEG
RUN curl -LO https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz && \
    tar xf ffmpeg-* && \
    mv ffmpeg-*/* /usr/local/bin/

# Install libvmaf
RUN git clone https://github.com/Netflix/vmaf.git /vmaf
WORKDIR /vmaf/libvmaf
RUN meson build --buildtype release && \
    ninja -vC build && \
    ninja -vC build test && \
    ninja -vC build install

# Install aomenc
COPY --from=registry.gitlab.com/luigi311/encoders-docker/aomenc:latest /usr/local/bin/aomenc /usr/local/bin

# Install svt-av1
COPY --from=registry.gitlab.com/luigi311/encoders-docker/svt-av1:latest /usr/local/bin/SvtAv1EncApp /usr/local/bin

# Install rav1e
COPY --from=registry.gitlab.com/luigi311/encoders-docker/rav1e:latest /rav1e/target/release rav1e/
RUN ln rav1e/rav1e /usr/local/bin/

# Install x265
COPY --from=registry.gitlab.com/luigi311/encoders-docker/x265:latest /usr/local/bin/x265 /usr/local/bin

# Install svt-hevc
COPY --from=registry.gitlab.com/luigi311/encoders-docker/svt-hevc:latest /usr/local/bin/SvtHevcEncApp /usr/local/bin

# Install x264
COPY --from=registry.gitlab.com/luigi311/encoders-docker/x264:latest /usr/local/bin/x264 /usr/local/bin

# Install vpxenc
COPY --from=registry.gitlab.com/luigi311/encoders-docker/vpxenc:latest /usr/local/bin/vpxenc /usr/local/bin

# Reset workdir to root
WORKDIR /
