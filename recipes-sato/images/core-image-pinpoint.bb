DESCRIPTION = "A very basic Wayland image with a terminal"

IMAGE_FEATURES += "splash package-management ssh-server-dropbear hwcodecs"

LICENSE = "MIT"

inherit core-image distro_features_check

REQUIRED_DISTRO_FEATURES = "systemd wayland pam"

CORE_IMAGE_BASE_INSTALL += "\
  connman \
  udev-extraconf \
  weston weston-init weston-examples \
  gtk+3-demo \
  gstreamer1.0 gstreamer1.0-plugins-base-meta gstreamer1.0-plugins-good-meta gstreamer1.0-plugins-bad-meta gstreamer1.0-libav gstreamer-vaapi \
  libgles2-mesa \
  pinpoint"

add_user_session () {
	mkdir --parents ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/graphical.target.wants
	ln -sf /lib/systemd/system/user-session@.service ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/graphical.target.wants/user-session@0.service

	mkdir --parents ${IMAGE_ROOTFS}${sysconfdir}/systemd/user/default.target.wants
	ln -sf /usr/lib/systemd/user/weston.target ${IMAGE_ROOTFS}${sysconfdir}/systemd/user/default.target.wants/weston.target
}

ROOTFS_POSTPROCESS_COMMAND += "add_user_session ; "
