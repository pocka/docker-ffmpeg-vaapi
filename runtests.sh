#!/bin/bash

VAAPI_ENABLED=${VAAPI_ENABLED:-false}
FFMPEG_X264="libx264"

if [[ "true" == "${VAAPI_ENABLED}" ]]; then
	VAAPI_DOCKER_ARGS="--privileged -v /dev/dri:/dev/dri"
	VAAPI_FFMPEG_ARGS="-vaapi_device /dev/dri/renderD128 -hwaccel vaapi -hwaccel_output_format vaapi"
	FFMPEG_X264="h264_vaapi"
fi

DIR=$(mktemp -d)
cd ${DIR}
curl -L -o test_mpeg2.mpg https://alcorn.com/wp-content/downloads/test-files/vid00001.mpg
docker run \
	${VAAPI_DOCKER_ARGS} \
	-v `pwd`:/data \
	ffmpeg:test \
	${VAAPI_FFMPEG_ARGS} \
	-i test_mpeg2.mpg \
	-c:v ${FFMPEG_X264} \
	-f matroska \
	test_mpeg2_${FFMPEG_X264}.mkv

