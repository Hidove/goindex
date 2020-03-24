#!/bin/bash
# BASEDIR="/www/wwwroot/down/电影"

BASEDIR="$1"
function hlsfile(){
	file="$1"
	if [[ "${file##*.}" == "mp4" || "${file##*.}" == "mkv" ]]; then
		filename="${file##*/}"
		hlsDir="${file%/*}/hls/${filename%.*}.mp4"
		if [[ ! -d "${hlsDir}" && ! -f "${file}.aria2" ]]; then
			echo -e "\e[33m\e[1m正在处理【${dirfile}】中\e[0m"
			mkdir -p "${hlsDir}"
			# Mkv转mp4
			if [[ "${file##*.}" == "mkv" ]]; then
				echo -e "\e[44m\e[1m【${filename}】Mkv转mp4中\e[0m"
				ffmpeg -i "${file}" -c:v copy -c:a copy "${file%.*}.mp4" > /dev/null 2>&1
				echo -e "\e[45m\e[1m【${filename}】Mkv转mp4成功！\e[0m"
				rm -f "${file}"
			fi
			echo -e "\e[33m\e[1m【${filename}】转hls中\e[0m"
			ffmpeg -i "${file%.*}.mp4" -c copy -bsf:v h264_mp4toannexb -hls_time 6 -hls_list_size 0 -hls_segment_filename "${hlsDir}/%04d.ts" "${hlsDir}/index.m3u8" > /dev/null 2>&1
			echo -e "\e[32m\e[1m【${filename}】转hls成功！\e[0m"
			echo -e "\e[32m\e[1m【${dirfile}】转化成功！\e[0m"
		fi
	fi
}

function scandir(){
	for dirfile in "$1"/*
	do
		if [[ -d "${dirfile}" && "${dirfile:0-5}" != "_h5ai" ]]; then
			scandir "${dirfile}"
		else
			hlsfile "${dirfile}"
		fi
	done
}
scandir "${BASEDIR}"

echo -e "\e[32m\e[1m【${BASEDIR}】所有mp4都已转化完毕！\e[0m"