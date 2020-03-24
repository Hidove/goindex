## 盘ta

* 一个goindex 修改版
* 更改播放器为dplayer、支持切片资源播放.
* 其他功能与原版相同.
* 切片需要安装`FFmpeg`

## 使用说明

* 安装

请参考原程序：<https://github.com/donwa/goindex>
修改本程序的`authConfig`参数即可

* shell脚本

```
bash mp42hls.sh "指定目录"
```
作用：将指定目录中的`mp4`、`mkv`转化为`hls`资源

```
bash mp42hlsFRclone.sh "云盘目录" "本地服务器目录"
```
作用：将指定云盘目录中的`mp4`、`mkv`转化为`hls`资源
解释：该脚本会将`云盘目录`文件全部copy到`本地服务器目录`，然后进行切片，之后再将hls上传到云盘中 