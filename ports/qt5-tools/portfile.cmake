include(vcpkg_common_functions)

include(${CURRENT_INSTALLED_DIR}/share/qt5modularscripts/qt_modular_library.cmake)

# Copy qt5-declarative tools and library
# This is a temporary workaround and hope to fix and remove it after the version update.
if (VCPKG_TARGET_IS_WINDOWS)
    if (EXISTS ${CURRENT_INSTALLED_DIR}/tools/qt5/Qt5Bootstrap.lib)
        message(STATUS "copy Qt5Bootstrap.lib")
        file(COPY ${CURRENT_INSTALLED_DIR}/tools/qt5/Qt5Bootstrap.lib DESTINATION ${CURRENT_INSTALLED_DIR}/lib)
        file(COPY ${CURRENT_INSTALLED_DIR}/tools/qt5/Qt5Bootstrap.prl DESTINATION ${CURRENT_INSTALLED_DIR}/lib)
        file(COPY ${CURRENT_INSTALLED_DIR}/tools/qt5/Qt5Bootstrap.lib DESTINATION ${CURRENT_INSTALLED_DIR}/debug/lib)
        file(COPY ${CURRENT_INSTALLED_DIR}/tools/qt5/Qt5Bootstrap.prl DESTINATION ${CURRENT_INSTALLED_DIR}/debug/lib)
    endif()
    if (EXISTS ${CURRENT_INSTALLED_DIR}/debug/tools/qt5-declarative/qmlimportscanner.exe)
        file(COPY ${CURRENT_INSTALLED_DIR}/debug/tools/qt5-declarative/qmlimportscanner.exe DESTINATION ${CURRENT_INSTALLED_DIR}/debug/tools/qt5/)
    endif()
    if (EXISTS ${CURRENT_INSTALLED_DIR}/tools/qt5-declarative/qmlimportscanner.exe)
        file(COPY ${CURRENT_INSTALLED_DIR}/tools/qt5-declarative/qmlimportscanner.exe DESTINATION ${CURRENT_INSTALLED_DIR}/tools/qt5/)
    endif()
endif()

qt_modular_library(qttools d37c0e11a26a21aa60f29f3b17ddc9895385d848692956e4481e49003cbe9c227daf8fda1c40a2ab70ac8e7e56d3771c1b2964524589eb77ac1f2362c269162e)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/tools/qt5-tools/plugins/platforminputcontexts)