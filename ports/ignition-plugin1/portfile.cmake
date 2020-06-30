include(${CURRENT_INSTALLED_DIR}/share/ignitionmodularscripts/ignition_modular_library.cmake)

set(PACKAGE_VERSION "1.1.0")
ignition_modular_library(NAME plugin
                         VERSION ${PACKAGE_VERSION}
                         REF "ignition-plugin_${PACKAGE_VERSION}"
                         SHA512 0657c5816e67d02329a79364050b8a56957180e5b7481b01696c7369b063cbfedfc93793a8ad92d87d242d24e476283dc7847bd810a3de98d3ec5ae7d640568c)
