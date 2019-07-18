include(vcpkg_common_functions)

include(${CURRENT_INSTALLED_DIR}/share/qt5modularscripts/qt_modular_library.cmake)

# Copy qt5-declarative tools
# This is a temporary workaround and hope to fix and remove it after the version update.
if (VCPKG_TARGET_IS_WINDOWS)
    if (EXISTS ${CURRENT_INSTALLED_DIR}/tools/qt5-declarative/qmlcachegen.exe)
        file(COPY ${CURRENT_INSTALLED_DIR}/tools/qt5-declarative/qmlcachegen.exe DESTINATION ${CURRENT_INSTALLED_DIR}/tools/qt5)
    endif()
endif()

qt_modular_library(qtvirtualkeyboard 1aa00fec7e333e4fd52891b82c239b532cf41657d9c3f44c6cc1c211a1412dbf5584823511e54f3feb33b3fed9c6e0171b55afde2df9f0a358e2e4885e1b2686)

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
