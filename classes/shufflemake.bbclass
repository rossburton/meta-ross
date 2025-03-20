# Force target recipes to depend on make-native and pass --shuffle

BASEDEPENDS:append:class-target = ' make-native'

EXTRA_OEMAKE:append:class-target = " --shuffle"
