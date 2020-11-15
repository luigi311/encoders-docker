# encoders-docker

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/0e63ec6ab000468f8c304e691dcded99)](https://www.codacy.com/manual/luigi311/encoders-docker/dashboard?utm_source=gitlab.com&utm_medium=referral&utm_content=Luigi311/encoders-docker&utm_campaign=Badge_Grade)  
Docker images for all video encoders for CI/CD or video encoding

## Currently Supported

-   aomenc
-   svt-av1
-   rav1e
-   x265
-   svt-hevc
-   x264
-   vpxenc

## Usage

Can be used in CI/CD for software involving encoders along with using them to encode local videos through command line. Recommended image to use is the main image located at registry.gitlab.com/luigi311/encoders-docker:latest which is based on ubuntu 20.04.

### Examples

#### aomenc

```bash
docker run -i registry.gitlab.com/luigi311/encoders-docker:latest aomenc --rt --cpu-used=9 --ivf /dev/stdin -o /dev/stdout < akiyo_cif.y4m > akiyo_cif.ivf
```

#### svt-av1

```bash
docker run -i registry.gitlab.com/luigi311/encoders-docker:latest SvtAv1EncApp --preset 8 -i /dev/stdin -b /dev/stdout < akiyo_cif.y4m > akiyo_cif.ivf
```

#### rav1e

Does not support stdin to feed it the video source so it has to be used as a base image for CI/CD or by mounting the folder with the video files into the image

```bash
docker run -v /home/luis/videos:/videos registry.gitlab.com/luigi311/encoders-docker:latest rav1e /videos/akiyo_cif.y4m -o /videos/akiyo_cif.ivf
```

#### x265

```bash
docker run -i registry.gitlab.com/luigi311/encoders-docker:latest x265 --y4m --preset 0 /dev/stdin -o /dev/stdout < akiyo_cif.y4m > akiyo_cif.h265
```

#### svt-hevc

Does not support stdin to feed it the video source so it has to be used as a base image for CI/CD or by mounting the folder with the video files into the image

```bash
docker run -v /home/luis/videos:/videos registry.gitlab.com/luigi311/encoders-docker:latest SvtHevcEncApp -i /videos/akiyo_cif.y4m -b akiyo_cif.bin
```

#### x264

```bash
docker run -i registry.gitlab.com/luigi311/encoders-docker:latest x264 --demuxer y4m --muxer mkv --preset 0 /dev/stdin -o /dev/stdout < akiyo_cif.y4m > akiyo_cif.mkv
```

#### vpxenc

```bash
docker run -i registry.gitlab.com/luigi311/encoders-docker:latest vpxenc --codec=vp9 --ivf --cpu-used=0 --passes=1 /dev/stdin -o /dev/stdout < akiyo_cif.y4m > akiyo_cif.ivf
```

#### svt-vp9

Does not support stdin to feed it the video source so it has to be used as a base image for CI/CD or by mounting the folder with the video files into the image. Only supports YUV so it requires manually setting the width, height and fps.

```bash
docker run -v /home/luis/videos:/videos registry.gitlab.com/luigi311/encoders-docker:latest SvtVp9EncApp -w 352 -h 288 -fps-num 24000 -fps-denom 1001 -i /videos/akiyo_cif.yuv -b akiyo_cif.bin
```
