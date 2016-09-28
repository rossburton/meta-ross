LICENSE = "GPLv2 & MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=b9ed56aa8997241d26cf7e4ff11745c9 \
                    file://shell/maynard.c;endline=22;md5=118a0e352ffc7336b7dfd6ac0e812d2d \
                    file://shell/panel.c;endline=20;md5=1c9eadff59e88978ca210c9ce673e057"

SRC_URI = "git://github.com/raspberrypi/maynard"

PV = "0.2.0+git${SRCPV}"
SRCREV = "5218638e800bab4f5cf83812f6cf3331d99a06a6"

S = "${WORKDIR}/git"

DEPENDS = "wayland-native wayland intltool-native alsa-lib gnome-desktop3 weston gtk+3 gnome-menus3"

inherit pkgconfig gettext autotools

FILES_${PN} += "${datadir}/glib-2.0/schemas ${libdir}/weston/"
