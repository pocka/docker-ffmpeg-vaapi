# docker-ffmpeg-vaapi

ffmpeg container with VAAPI.

Recommended: use 3.x kernel. May not works on latest kernel.

## Install

```sh
docker pull pocka/ffmpeg-vaapi
```

## Example

+ input:  `/data/test-input.ts`
+ output: `/data/test-out.mp4`

```sh
docker run \
  --privileged \
  -v /dev/dri:/dev/dri \
  -v /data:/data \
  pocka/ffmpeg-vaapi \
    -vaapi_device /dev/dri/renderD128 \
    -hwaccel vaapi \
    -hwaccel_output_format vaapi \
    -i /data/test-input.ts \
    -vf 'format=nv12|vaapi,hwupload,scale_vaapi=w=1280:h=720' \
    -level 41 \
    -c:v h264_vaapi \
    -aspect 16:9 \
    -qp 23 \
    -c:a copy \
    -movflags faststart \
    -vsync 1 \
    /data/test-out.mp4
```
