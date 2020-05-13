FROM python:3

# Install requirements
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        cmake \
        gcc \
        g++ \
        make \
        nasm \
        parallel \
        ffmpeg \
        ninja-build \
        doxygen
RUN pip install --no-cache-dir meson

# Install libvmaf
RUN git clone https://github.com/Netflix/vmaf.git /tmp/vmaf && \
    cd /tmp/vmaf/libvmaf && \
    meson build --buildtype release && \
    ninja -vC build && \
    ninja -vC build install

# Install aomenc
RUN git clone https://aomedia.googlesource.com/aom /tmp/aomenc && \
    mkdir -p /tmp/aom_build && \
    cd /tmp/aom_build && \
    cmake -DENABLE_SHARED=off -DENABLE_NASM=on -DCMAKE_BUILD_TYPE=Release -DCONFIG_TUNE_VMAF=1 /tmp/aomenc && \
    make -j$(NPROC) && \
    make install
