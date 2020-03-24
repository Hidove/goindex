#!/bin/bash
# 改版本用于rclone中的视频切片
# /Drive/电影 rclone挂载目录 + 需要切片的目录
BASEDIR="$1"
#克隆地址 本地服务器保存地址
# /www/wwwroot
BASECLONEDIR="$2"
if [ ! -n "$BASEDIR" ];then
	echo "BASEDIR can not be null!"
	exit
fi
function hlsfile(){
	file="$1"
	filename="${file##*/}"
	if [[ "${file##*.}" == "mp4" || "${file##*.}" == "mkv" ]]; then
		#先克隆到本地
		cloneFile="${BASECLONEDIR}/Clone${file}"
		if [[ ! -d "${cloneFile}" ]];then
			rclone mkdir "${cloneFile%/*}"
		fi
		echo -e "\e[44m\e[1m正在Rclone【${file}】to【${cloneFile}】中\e[0m"
		rclone copy "${file%/*}" "${cloneFile%/*}" 
		echo -e "\e[45m\e[1m【${file}】Rclone success~\e[0m"
		hlsDir="${cloneFile%/*}/hls/${filename%.*}.mp4"
		if [[ ! -d "${hlsDir}" && ! -f "${cloneFile}.aria2" ]]; then
			echo -e "\e[33m\e[1m正在处理【${dirfile}】中\e[0m"
			rclone mkdir "${hlsDir}"
			# Mkv转mp4
			if [[ "${cloneFile##*.}" == "mkv" ]]; then
				echo -e "\e[44m\e[1m【${filename}】Mkv转mp4中\e[0m"
				ffmpeg -i "${cloneFile}" -c:v copy -c:a copy "${cloneFile%.*}.mp4" > /dev/null 2>&1
				echo -e "\e[45m\e[1m【${filename}】Mkv转mp4成功！\e[0m"
				#删除本地的mkv文件
				rm -f "${cloneFile}"
				#删除网盘的mkv文件
				rm -f "${file}"
			fi
			echo -e "\e[31m\e[1m【${filename}】转hls中\e[0m"
			ffmpeg -i "${cloneFile%.*}.mp4" -c copy -bsf:v h264_mp4toannexb -hls_time 1 -hls_list_size 0 -hls_segment_filename "${hlsDir}/%04d.ts" "${hlsDir}/index.m3u8" > /dev/null 2>&1
			echo -e "\e[37m\e[1m【${filename}】转hls成功！\e[0m"
			if [[ ! -d "${file%/*}/hls/${filename%.*}.mp4" ]]; then
				rclone mkdir "${file%/*}/hls/${filename%.*}.mp4"
			fi
			echo -e "\e[35m\e[1m准备上传【${filename}】hls文件\e[0m"
			# 上传hls
			rclone move "${hlsDir}" "${file%/*}/hls/${filename%.*}.mp4" --delete-empty-src-dirs
			echo -e "\e[36m\e[1m上传【${filename}】hls文件成功\e[0m"
			if [[ "${cloneFile##*.}" == "mkv" ]]; then
				# 上传mp4
				echo -e "\e[33m\e[1m【${filename}】是mkv视频，准备上传mp4版本\e[0m"
				rclone move "${cloneFile%.*}.mp4" "${file%.*}.mp4" --delete-empty-src-dirs
				echo -e "\e[32m\e[1m【${filename}】mp4版本上传完毕\e[0m"
			fi
			echo -e "\e[32m\e[1m【${dirfile}】处理完毕！\e[0m"
			rm -f "${cloneFile%.*}.mp4"
		fi
	fi
}

function scandir(){
	for dirfile in "$1"/*
	do
		filename="${dirfile##*/}"
		if [ "${filename}" == "hls" ];then
			echo -e "\e[31m\e[1m【${dirfile}】为hls目录，跳过！\e[0m"
			continue
		elif [ -d "${dirfile}/hls" ];then
			echo -e "\e[32m\e[1m【${dirfile}】已切片，跳过！\e[0m"
			continue
		elif [[ -d "${dirfile}" && "${dirfile:0-5}" != "_h5ai" ]];then
			scandir "${dirfile}"
		else
			hlsfile "${dirfile}"
		fi
	done
}
scandir "${BASEDIR}"

echo -e "\e[32m\e[1m【${BASEDIR}】所有mp4都已转化完毕！\e[0m"