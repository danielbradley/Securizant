<image name="vfs.e2" mountpoint="/" script="scripts/vfs.script">
<dir path="/local"/>
<dir path="/tools"/>
<dir path="/bin"/>
<dir path="/mnt"/>
<dir path="/sys"/>
<dir path="/system"/>
<dir path="/usr"/>
<dir path="/usr/bin"/>
<link location="/bin/bash"          target="../tools/bin/bash"/>
<link location="/bin/sh"            target="../tools/bin/sh"/>
<link location="/bin/cat"           target="../tools/bin/cat"/>
<link location="/bin/pwd"           target="../tools/bin/pwd"/>
<link location="/bin/stty"          target="../tools/bin/stty"/>
<link location="/bin/rm"            target="../tools/bin/rm"/>
<link location="/dev"               target="system/devices"/>
<link location="/home"              target="local/users"/>
<link location="/lib"               target="system/software/lib"/>
<link location="/local/settings"    target="../system/mounts/TEMP/settings"/>
<link location="/local/data"        target="../system/mounts/TEMP/data"/>
<link location="/local/users"       target="../system/mounts/TEMP/users"/>
<link location="/local/log"         target="../system/mounts/TEMP/log"/>
<link location="/opt"               target="local/software"/>
<link location="/proc"              target="system/processes"/>
<link location="/sbin"              target="system/software/sbin"/>
<link location="/tmp"               target="system/mounts/TEMP"/>
<link location="/usr/include"       target="../system/software/include"/>
<link location="/usr/X11R6"         target="../system/software/X11R6"/>
<link location="/var"               target="local/data/_system"/>
</image>
