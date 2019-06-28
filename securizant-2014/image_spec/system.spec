<image name="system.e2" mountpoint="/system" mountflags="loop" fs="ext2" script="scripts/system.script" size="500">
<dir path="/accounts/application"/>
<dir path="/accounts/commands"/>
<dir path="/accounts/guest"/>
<dir path="/accounts/library"/>
<dir path="/accounts/root"/>
<dir path="/accounts/runtime"/>
<dir path="/accounts/service"/>
<dir path="/accounts/software"/>
<dir path="/accounts/system"/>
<dir path="/default/settings"     source="static/default_settings/2008"/>
<dir path="/default/software"/>
<dir path="/default/data/_system"/>
<dir path="/default/data/_system/lib"/>
<dir path="/default/data/_system/log"/>
<dir path="/default/data/_system/run"/>
<dir path="/default/settings/users/skel"   source="static/default_user"/>
<dir path="/default/shared"/>
<dir path="/default/shared/documents"/>
<dir path="/default/shared/downloads"/>
<dir path="/default/shared/fonts"/>
<dir path="/default/shared/media"/>
<dir path="/default/shared/movies"/>
<dir path="/default/shared/music"/>
<dir path="/default/shared/pictures"/>
<dir path="/default/users"/>

<dir path="/devices"/>
<dir path="/features"/>
<dir path="/mounts/INITRD"/>
<dir path="/mounts/SYS"/>
<dir path="/mounts/SYSTEM_MEDIA"/>
<dir path="/mounts/TEMP"/>
<dir path="/mounts/VAR"/>
<dir path="/software/applications"/>
<dir path="/software/commands"/>
<dir path="/software/commands/development"/>
<dir path="/software/drivers"/>
<dir path="/software/kernels"/>
<dir path="/software/libraries"/>
<dir path="/software/runtimes"/>
<dir path="/software/services"/>
<dir path="/software/bin"/>
<dir path="/software/doc"/>
<dir path="/software/include"/>
<dir path="/software/info"/>
<dir path="/software/lib"/>
<dir path="/software/lib/lsb"      source="static/lsb"/>
<dir path="/software/man/man1"/>
<dir path="/software/man/man2"/>
<dir path="/software/man/man3"/>
<dir path="/software/man/man4"/>
<dir path="/software/man/man5"/>
<dir path="/software/man/man6"/>
<dir path="/software/man/man7"/>
<dir path="/software/man/man8"/>
<dir path="/software/man/man9"/>
<dir path="/software/sbin"/>
<dir path="/software/share"/>
<dir path="/software/source/linux/include"/>
<dir path="/software/source/kernels"/>
<dir path="/startup/modules"       source="static/startup_modules"/>
<dir path="/startup/configuration" source="static/startup_configuration"/>
<dir path="/startup/devices"       source="static/startup_devices"/>

<link location="/default/settings/lsb/X11"           target="../desktop"/>
<link location="/default/settings/lsb/fonts"         target="../fonts"/>
<link location="/default/settings/lsb/fstab"         target="../system/meta/partitions"/>
<link location="/default/settings/lsb/group"         target="../users/group"/>
<link location="/default/settings/lsb/ld.so.conf"    target="../system/meta/ld.so.conf"/>
<link location="/default/settings/lsb/login.defs"    target="../users/meta/login.defs"/>
<link location="/default/settings/lsb/passwd"        target="../users/passwd"/>
<link location="/default/settings/lsb/profile"       target="../users/meta/profile"/>
<link location="/default/settings/lsb/shadow"        target="../private/shadow"/>
<link location="/default/settings/lsb/shells"        target="../users/meta/shells"/>
<link location="/default/settings/lsb/system.bashrc" target="../users/meta/system.bashrc"/>

<link location="/mounts/TEMP/settings" target="../../default/settings"/>
<link location="/mounts/TEMP/data"     target="../../default/data"/>

<link location="/startup/modules/halt.script"   target="shutdown.script"/>
<link location="/startup/modules/reboot.script" target="shutdown.script"/>

<link location="/software/include/asm"         target="../source/linux/include/asm"/>
<link location="/software/include/linux"       target="../source/linux/include/linux"/>
<link location="/software/include/X11"         target="../X11R6/include/X11"/>
<link location="/software/lib/modules"         target="../drivers"/>
<link location="/software/X11R6"               target="../features/desktop"/>
</image>
