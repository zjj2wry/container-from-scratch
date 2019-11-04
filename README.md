# container-from-scratch
build a container from scratch

## build base images

- https://docs.docker.com/develop/develop-images/baseimages/
- https://github.com/moby/moby/blob/master/contrib/mkimage/busybox-static

setup rootfs
```
vagrant up
vagrant ssh
chmod +x busybox-static
./busybox-static myrootfs
```

create an isolated rootfs with chroot
```bash
vagrant@vagrant:/vagrant$ sudo chroot myrootfs/ bin/sh


BusyBox v1.22.1 (Ubuntu 1:1.22.0-15ubuntu1.4) built-in shell (ash)
Enter 'help' for a list of built-in commands.

/ #
```

## linux namespace

- https://lwn.net/Articles/531114/
- http://www.haifux.org/lectures/299/netLec7.pdf
- http://www.sel.zju.edu.cn/?p=556

example
```bash
# Establish a PID namespace, ensure we're PID 1 in it against newly mounted procfs instance.
vagrant@vagrant:~$ sudo unshare --fork --pid --mount-proc readlink /proc/self
1
# Establish a user namespace as an unprivileged user with a root user within it.
vagrant@vagrant:~$ unshare --map-root-user --user sh -c whoami
root
# Establish a persistent UTS namespace, modify hostname. The namespace maybe later entered by nsenter. The namespace is destroyed by umount the bind reference.
vagrant@vagrant:~$ sudo touch /root/uts-ns
vagrant@vagrant:~$ sudo unshare --uts=/root/uts-ns
root@vagrant:~# hostname foo
root@vagrant:~# exit
logout
vagrant@vagrant:~$ sudo nsenter --uts=/root/uts-ns hostname
foo
```

create an isolated container environment using linux namespace
```bash
# create an isolated environment, container network is worth discussing separately
vagrant@vagrant:/vagrant$ sudo unshare --uts --mount --pid --uts --fork
root@vagrant:/vagrant# pstree
systemd-+-VBoxService-+-{automount}
        |             |-{control}
        ...
        |-sshd---sshd---sshd---bash---sudo---unshar
# view current process id
root@vagrant:/vagrant# echo $$
1
root@vagrant:/vagrant# ls
README.md  Vagrantfile  busybox-static  myrootfs
root@vagrant:/vagrant# sudo chroot myrootfs/ bin/sh

BusyBox v1.22.1 (Ubuntu 1:1.22.0-15ubuntu1.4) built-in shell (ash)
Enter 'help' for a list of built-in commands.

# the generated rootfs does not have /proc /sys, created manually
/ # ps -ef
PID   USER     COMMAND
ps: can't open '/proc': No such file or directory
/ # ls
bin   sbin  usr
/ # mkdir -p /proc
/ # /bin/mount -t proc proc /proc
# ps -ef only see your own process information
/ # ps -ef
PID   USER     COMMAND
    1 0        -bash
   13 0        sudo chroot myrootfs/ bin/sh
   14 0        bin/sh
   21 0        {exe} ps -ef
```