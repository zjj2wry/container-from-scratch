# container-from-scratch
build a container from scratch

## build base images

- https://docs.docker.com/develop/develop-images/baseimages/
- https://github.com/moby/moby/blob/master/contrib/mkimage/busybox-static

setup rootfs
```bash
vagrant up
vagrant ssh
chmod +x busybox-static
./busybox-static myrootfsls
```