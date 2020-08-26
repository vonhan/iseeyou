# iseeyou
iseeyou API for object detection with YOLOv3

## References
[YOLOv3](https://pjreddie.com/darknet/yolo/)
[opencv](https://github.com/stempler/schickling-dockerfiles/tree/master/opencv)
[yolo3-docker](https://github.com/stigtsp/yolo3-docker)

### yolo3-docker
Docker part copied from:
https://github.com/stigtsp/yolo3-docker
```
$ docker build -t yolo3-docker .
$ xhosts + #This makes your X insecure!
$ docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix yolo3-docker ./darknet detect cfg/yolov3.cfg yolov3.weights data/dog.jpg
```

### Get started
Just type:
```
$ docker run -it --name faraday -p 5000:5000 -d lucamotta/iseeyou:latest
```

# API

### Requests

`GET /`

    curl -i -H 'Accept: application/json' http://localhost:5000/

`POST /detect/`

    curl -i -H 'Accept: application/json' -d 'img=<image_in_base64>' http://localhost:500/detect