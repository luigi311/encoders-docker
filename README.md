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

Encoding via commandline requires either feeding the video in via stdin and out via stdout (Linux/WSL) or via volume mounting (Windows/Linux/WSL).  
Linux volume mounting

> \-v /home/luigi311/Videos:/videos

or if you are in the current directory

> \-v $(pwd):/videos

Windows will not work with c:\\Users\\luigi311\\Videos structure so $(pwd) will not work on windows, you must convert it to

> \-v //c/Users/luigi311/Videos:/videos

### Examples

#### aomenc

Stdin/Stdout (Linux/WSL)

```bash
docker run -i registry.gitlab.com/luigi311/encoders-docker:latest aomenc --rt --cpu-used=9 --ivf /dev/stdin -o /dev/stdout < akiyo_cif.y4m > akiyo_cif.ivf
```

Volume Mount (Windows/Linux/WSL)

```powershell
docker run -v //c/Users/luigi311/Videos:/videos registry.gitlab.com/luigi311/encoders-docker:latest aomenc --rt --cpu-used=9 --ivf /videos/akiyo_cif.y4m -o /videos/akiyo_cif.ivf
```

#### svt-av1

Stdin/Stdout (Linux/WSL)

```bash
docker run -i registry.gitlab.com/luigi311/encoders-docker:latest SvtAv1EncApp --preset 8 -i /dev/stdin -b /dev/stdout < akiyo_cif.y4m > akiyo_cif.ivf
```

Volume Mount (Windows/Linux/WSL)

```bash
docker run -v //c/Users/luigi311/Videos:/videos registry.gitlab.com/luigi311/encoders-docker:latest SvtAv1EncApp --preset 8 -i /videos/akiyo_cif.y4m -b /videos/akiyo_cif.ivf
```

#### rav1e

Stdin/Stdout (Linux/WSL)

Does not support stdin to feed it the video source so it has to be used as a base image for CI/CD or by mounting the folder with the video files into the image

Volume Mount (Windows/Linux/WSL)

```powershell
docker run -v //c/Users/luigi311/Videos:/videos registry.gitlab.com/luigi311/encoders-docker:latest rav1e /videos/akiyo_cif.y4m -o /videos/akiyo_cif.ivf
```

#### x265

Stdin/Stdout (Linux/WSL)

```bash
docker run -i registry.gitlab.com/luigi311/encoders-docker:latest x265 --y4m --preset 0 /dev/stdin -o /dev/stdout < akiyo_cif.y4m > akiyo_cif.h265
```

Volume Mount (Windows/Linux/WSL)

```bash
docker run -v //c/Users/luigi311/Videos:/videos registry.gitlab.com/luigi311/encoders-docker:latest x265 --y4m --preset 0 /videos/akiyo_cif.y4m -o /videos/akiyo_cif.h265
```

#### svt-hevc

Stdin/Stdout (Linux/WSL)
Does not support stdin to feed it the video source so it has to be used as a base image for CI/CD or by mounting the folder with the video files into the image

Volume Mount (Windows/Linux/WSL)

```bash
docker run -v //c/Users/luigi311/Videos:/videos registry.gitlab.com/luigi311/encoders-docker:latest SvtHevcEncApp -i /videos/akiyo_cif.y4m -b /videos/akiyo_cif.bin
```

#### x264

Stdin/Stdout (Linux/WSL)

```bash
docker run -i registry.gitlab.com/luigi311/encoders-docker:latest x264 --demuxer y4m --muxer mkv --preset 0 /dev/stdin -o /dev/stdout < akiyo_cif.y4m > akiyo_cif.mkv
```

Volume Mount (Windows/Linux/WSL)

```bash
docker run -v //c/Users/luigi311/Videos:/videos registry.gitlab.com/luigi311/encoders-docker:latest x264 --demuxer y4m --muxer mkv --preset 0 /videos/akiyo_cif.y4m -o /videos/akiyo_cif.mkv
```

#### vpxenc

Stdin/Stdout (Linux/WSL)

```bash
docker run -i registry.gitlab.com/luigi311/encoders-docker:latest vpxenc --codec=vp9 --ivf --cpu-used=0 --passes=1 /dev/stdin -o /dev/stdout < akiyo_cif.y4m > akiyo_cif.ivf
```

Volume Mount (Windows/Linux/WSL)

```bash
docker run -v //c/Users/luigi311/Videos:/videos registry.gitlab.com/luigi311/encoders-docker:latest vpxenc --codec=vp9 --ivf --cpu-used=0 --passes=1 /videos/akiyo_cif.y4m -o /videos/akiyo_cif.ivf
```
