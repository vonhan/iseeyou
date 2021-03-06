# Based on https://github.com/stigtsp/yolo3-docker
FROM debian:stretch

# Based in part on on schickling/opencv by Johannes Schickling <schickling.j@gmail.com>
ARG OPENCV_VERSION="4.0.1"

# install dependencies
RUN apt-get update -y
RUN apt-get install -y libopencv-dev yasm libjpeg-dev libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev libv4l-dev python-dev python-numpy libtbb-dev libqt4-dev libgtk2.0-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev x264 v4l-utils pkg-config curl build-essential checkinstall cmake python-pip

# download opencv
RUN curl -sL https://github.com/opencv/opencv/archive/$OPENCV_VERSION.tar.gz | tar xvz -C /tmp

RUN mkdir -p /tmp/opencv-$OPENCV_VERSION/build

WORKDIR /tmp/opencv-$OPENCV_VERSION/build

# install
RUN cmake -DWITH_FFMPEG=OFF -DWITH_OPENEXR=OFF -DBUILD_TIFF=OFF -DWITH_CUDA=OFF -DWITH_NVCUVID=OFF -DBUILD_PNG=OFF ..
RUN make
RUN make install

# configure
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf
RUN ldconfig
RUN ln /dev/null /dev/raw1394 # hide warning - http://stackoverflow.com/questions/12689304/ctypes-error-libdc1394-error-failed-to-initialize-libdc1394

WORKDIR /

RUN apt-get install -y git wget


WORKDIR /

RUN git clone https://github.com/pjreddie/darknet
RUN cd darknet && perl -pi -e 's/OPENCV=0/OPENCV=1/gs' Makefile && make -j3

WORKDIR /darknet
RUN wget https://pjreddie.com/media/files/yolov3.weights

WORKDIR /

RUN mkdir iseeyou
WORKDIR /iseeyou
COPY /app /iseeyou/app
#RUN git clone https://github.com/vonhan/iseeyou.git
RUN pip install flask
WORKDIR /iseeyou/app
ENV FLASK_APP=server.py
CMD ["flask", "run", "--host=0.0.0.0"] 
# # cleanup package manager
# RUN apt-get remove --purge -y curl build-essential checkinstall cmake
# RUN apt-get autoclean && apt-get clean
# RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*





