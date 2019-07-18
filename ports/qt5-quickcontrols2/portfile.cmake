include(vcpkg_common_functions)

include(${CURRENT_INSTALLED_DIR}/share/qt5modularscripts/qt_modular_library.cmake)

# Copy qt5-declarative tools
# This is a temporary workaround and hope to fix and remove it after the version update.
if (VCPKG_TARGET_IS_WINDOWS)
    if (EXISTS ${CURRENT_INSTALLED_DIR}/tools/qt5-declarative/qmlcachegen.exe)
        file(COPY ${CURRENT_INSTALLED_DIR}/tools/qt5-declarative/qmlcachegen.exe DESTINATION ${CURRENT_INSTALLED_DIR}/tools/qt5)
    endif()
endif()

qt_modular_library(qtquickcontrols2 afc1ae9a5a046845b085d5cf0019b79d99914a2d285676bd4d8966f1302513078c8279b71134281c03b2c1209295bca438b9e255774574520498b0b5385bad27)
