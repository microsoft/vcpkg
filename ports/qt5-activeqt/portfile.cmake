include(vcpkg_common_functions)

if (NOT VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "qt5-activeqt only support Windows.")
endif()

include(${CURRENT_INSTALLED_DIR}/share/qt5modularscripts/qt_modular_library.cmake)

qt_modular_library(qtactiveqt  1a1560424ed8f6075ffe371efaff63ae9aa52377aa84f806a39d7e995960a7d7eeb1eb575470b13569293d2623c5e247204397d8b6698c1ce2ff9f206850a912)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/tools/qt5-activeqt/plugins/platforminputcontexts)
