<image name="boot.e2" mountpoint="/system/mounts/INITRD" mountflags="loop" fs="ext2" script="scripts/initrd.script" size="50">
<dir path="/bin"/>
<dir path="/dev"/>
<dir path="/linuxrc.d" source="static/linuxrc.d"/>
<dir path="/mounts"/>
<dir path="/mounts/DEV"/>
<dir path="/mounts/LOCAL"/>
<dir path="/mounts/PROC"/>
<dir path="/mounts/ROOT"/>
<dir path="/mounts/SYSTEM_MEDIA"/>
<dir path="/mounts/VFS"/>
<dir path="/mounts/sys"/>
<dir path="/vfs"/>
<link location="/proc" target="mounts/PROC"/>
</image>
