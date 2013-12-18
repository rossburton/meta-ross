DESCRIPTION = "Image with just the Sato user interface and a terminal"

IMAGE_FEATURES += "splash package-management x11-base ssh-server-dropbear hwcodecs"

LICENSE = "MIT"

inherit core-image

CORE_IMAGE_EXTRA_INSTALL += "packagegroup-core-x11-sato-base"
