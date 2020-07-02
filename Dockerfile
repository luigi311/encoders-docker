FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        python3 \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        python3-docutils \
        build-essential \
        ninja-build && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir meson

# Install FFMPEG
RUN curl -LO https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz && \
    tar xf ffmpeg-git-amd64-static.tar.xz && \
    mv ffmpeg-*/* /usr/local/bin/

# Install libvmaf
RUN git clone https://github.com/Netflix/vmaf.git /vmaf
WORKDIR /vmaf/libvmaf
RUN meson build --buildtype release && \
    ninja -vC build || ninja -vC build && \
    ninja -vC build install

# Install aomenc
COPY --from=registry.gitlab.com/luigi311/av1-docker:aomenc /aom_build/aomenc /usr/local/bin

# Install svt-av1
COPY --from=registry.gitlab.com/luigi311/av1-docker:svt-av1 /SVT-AV1/Bin/Release/SvtAv1EncApp /usr/local/bin

# Install rav1e
COPY --from=registry.gitlab.com/luigi311/av1-docker:rav1e rav1e/target/release rav1e/
RUN ln rav1e/rav1e /usr/local/bin/

# Test Encoders
RUN aomenc --help && \
    SvtAv1EncApp --help && \
    rav1e --help 