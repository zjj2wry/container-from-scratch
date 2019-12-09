contid=$(printf '%x%x%x%x' $RANDOM $RANDOM $RANDOM $RANDOM)

cgcreate -g cpu,cpuacct,memory:/"$contid"
cgset -r cpu.cfs_quota_us=100000 "$contid"/
cgset -r memory.limit_in_bytes=100m "$contid"/
cgexec -g cpu,cpuacct,memory:/"$contid" \
    unshare --uts --mount --pid --uts --fork \
    chroot myrootfs/ bin/sh -c "mkdir -p /proc && /bin/mount -t proc proc /proc && $@"
