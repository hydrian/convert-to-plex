#!/bin/bash -x

### Defaults ###
LOW_QUALITY_VIDEO_CODEC_DEFAULT="x264"
HIGH_QUALITY_VIDEO_CODEC_DEFAULT="x265"
ALLOWED_VIDEO_CONTAINERS_DEFAULTS=(
	"mkv"
	"mp4"
)
ALLOWED_VIDEO_CODEC_DEFAULTS=("x264" "x265")
CONVERTED_FILE_CONTAINER_DEFAULT="mkv"
FIND_DIR="${FIND_DIR:=.}"
### Environment check ###
MEDIAINFO_BIN=$(which mediainfo)
if [ $? -ne 0 ] ; then
	echo "Could not locate mediainfo binary. Please install." 1>&2
	exit 2
fi
FFMPEG_BIN=$(which ffmpeg)
if [ $? -ne 0 ] ; then
	echo "Could not locate ffmpeg executable. Please install."	exit 2
fi
JQ_BIN=$(which jq)
if [ $? -ne 0 ] ; then
	echo "Could not locate jq executable. Please install."
	exit 2
fi

### Internal Variables ###
VIDEO_EXTS=(
	"avi"
	"mp4"
	"rm"
	"mkv"
	"wmv"
	"m4v"
	"ogm"
	"ogv"
)

ALLOWED_VIDEO_CONTAINERS=(
	"mp4"
	"mkv"
)

ALLOWED_VIDEO_CODECS=${ALLOWED_VIDEO_CODECS:-$ALLOWED_VIDEO_CODEC_DEFAULTS}

### Functions ###
function clean-up {
	test -e "${VIDEO_LIST_FILE}" && rm "${VIDEO_LIST_FILE}"
	return 0 
}

function show-help {
	echo "HELP!"
	echo "  -d DIR     default: ."
	return 0
}

### Main process ###
V_CNT=0
V_EXT_LIST=''
for V_EXT in "${VIDEO_EXTS[@]}" ; do
  if [ $V_CNT -gt 0 ] ; then
		V_EXT_LIST+=" -or"
	fi
	V_EXT_LIST+=" -iname \*.${V_EXT}"
	V_CNT=$((V_CNT + 1))
done
FIND_CMD="find ${FIND_DIR} -type f -and  ( ${V_EXT_LIST}  )"
TEMP_MASTER_FILE_LIST="$(mktemp)"
if [ $? -ne 0 ] ; then
	echo "Failed to create TEMP_MASTER_FILE" 1>&2
	exit 2
fi

${FIND_CMD} 1>"${TEMP_MASTER_FILE_LIST}"
if [ $? -ne 0 ] ; then
	echo "Failed to search ${FIND_DIR}" 1>&2
	exit 2
fi

