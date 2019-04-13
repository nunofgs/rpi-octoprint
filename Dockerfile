ARG arch

# Intermediate build container with arm support.
FROM hypriot/qemu-register as qemu
FROM $arch/python:2.7-slim as build

COPY --from=qemu /qemu-arm /usr/bin/qemu-arm-static

ARG version

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
  avrdude \
  build-essential \
  cmake \
  git \
  haproxy \
  imagemagick \
  libav-tools \
  v4l-utils \
  libjpeg-dev \
  libjpeg62-turbo \
  libprotobuf-dev \
  libv4l-dev \
  psmisc \
  supervisor \
  unzip \
  wget \
  zlib1g-dev


## Install mjpeg streamer
WORKDIR /usr/app
RUN git clone https://github.com/jacksonliam/mjpg-streamer.git .

WORKDIR /usr/app/mjpg-streamer-experimental
RUN make 
RUN export LD_LIBRARY_PATH=.
COPY ./mjpg_streamer_plugins/* /usr/app/mjpg-streamer-experimental/


# Install OctoPrint
WORKDIR /usr/app
RUN wget -qO- https://github.com/foosel/OctoPrint/archive/${version}.tar.gz | tar xz
WORKDIR /usr/app/OctoPrint-${version}
RUN pip install -r requirements.txt
RUN python setup.py install


VOLUME /data
WORKDIR /data

COPY haproxy.cfg /etc/haproxy/haproxy.cfg
COPY supervisord.conf /etc/supervisor/supervisord.conf

ENV MJPEG_STREAMER_INPUT input_uvc.so -y -n -r 640x480 -d /dev/video0
ENV MJPEG_STREAMER_AUTOSTART true
ENV PIP_USER true
ENV PYTHONUSERBASE /data/plugins

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
