# OctoPrint

[![build status][travis-image]][travis-url]

This is a Dockerfile to set up [OctoPrint](http://octoprint.org/). It supports the following architectures automatically:

- x86
- arm32v6 (Raspberry Pi, etc.)

# Tags

- `1.3.10`, `latest` ([Dockerfile](https://github.com/nunofgs/docker-octoprint/blob/master/Dockerfile))
- `1.3.9` ([Dockerfile](https://github.com/nunofgs/docker-octoprint/blob/master/Dockerfile))
- `1.3.8` ([Dockerfile](https://github.com/nunofgs/docker-octoprint/blob/master/Dockerfile))
- `1.3.7` ([Dockerfile](https://github.com/nunofgs/docker-octoprint/blob/master/Dockerfile))
- `1.3.6` ([Dockerfile](https://github.com/nunofgs/docker-octoprint/blob/master/Dockerfile))
- `master` (_Automatically built daily from OctoPrint's `master` branch_)

# Tested devices

| Device              | Working? |
| ------------------- | -------- |
| Raspberry Pi 2b     | ✅        |
| Raspberry Pi 3b+    | ✅        |
| Raspberry Pi Zero W | ❌        |

# Usage

```shell
$ docker run \
  --device=/dev/video0 \
  -p 80:80 \
  -v /mnt/data:/data \
  nunofgs/octoprint
```

# Environment Variables

| Variable                 | Description                              | Default Value                                  |
| ------------------------ | ---------------------------------------- | ---------------------------------------------- |
| MJPEG_STREAMER_INPUT     | The input plugin config of mjpg-streamer | `input_uvc.so -y -n -r 640x480 -d /dev/video0` |
| MJPEG_STREAMER_AUTOSTART | Start the camera automatically           | `true`                                         |

# CuraEngine integration

Cura engine integration was very outdated (using version `15.04.6`) and was removed.

It will return once OctoPrint [supports python3](https://github.com/foosel/OctoPrint/pull/1416#issuecomment-371878648) (needed for the newest versions of cura engine).

# Webcam integration

## USB Webcam
1. Bind the camera to the docker using --device=/dev/videoX:/dev/video0
2. Optionally, change `MJPEG_STREAMER_INPUT` to your preferred settings (ex: `input_uvc.so -y -n -r 640x480 -d /dev/video0`)

## Raspberry Pi camera module
1. The camera module must be activated (sudo raspi-config -> interfacing -> Camera -> set it to YES)
2. Memory split must be at least 128mb, 256mb recommended. (sudo raspi-config -> Advanced Options -> Memory Split -> set it to 128 or 256)
3. You must allow acess to device: /dev/vchiq
4. Change `MJPEG_STREAMER_INPUT` to use input_raspicam.so (ex: `input_raspicam.so -fps 25`)

Rpi camera module container example: 
```shell
$ docker run \
  -name octoprint \
  -device /dev/vchiq \
  -env MJPEG_STREAMER_INPUT='input_raspicam.so -fps 25' \
  -p 80:80 \
  -v /mnt/data:/data \
  nunofgs/octoprint
```

## Octoprint configuration

Use the following settings in octoprint:

```yaml
webcam:
  stream: /webcam/?action=stream
  snapshot: http://127.0.0.1:8080/?action=snapshot
  ffmpeg: /usr/bin/ffmpeg
```

# Notes

This image uses `supervisord` in order to launch 3 processes: _haproxy_, _octoprint_ and _mjpeg-streamer_.

This means you can disable/enable the camera at will from within octoprint by editing your `config.yaml`:

```yaml
system:
  actions:
  - action: streamon
    command: supervisorctl start mjpeg-streamer
    confirm: false
    name: Start webcam
  - action: streamoff
    command: supervisorctl stop mjpeg-streamer
    confirm: false
    name: Stop webcam
```

# Credits

Original credits go to https://bitbucket.org/a2z-team/docker-octoprint. I initially ported this to the raspberry pi 2 and later moved to a multiarch image.

## License

MIT

[travis-image]: https://img.shields.io/travis/nunofgs/docker-octoprint.svg?style=flat-square
[travis-url]: https://travis-ci.org/nunofgs/docker-octoprint
