vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kio
    REF "v${VERSION}"
    SHA512 686ac09d2ddaf3ce13df617a55e76fcac335e47a6c729d7482d4096d6eca199fe163155d51a4d7619c055ca74b0a048f9f1d173dacdd848689753d4a5599de76
    HEAD_REF master
    PATCHES
        fix-static-dependencies.patch
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        designerplugin BUILD_DESIGNERPLUGIN
        kwallet        VCPKG_LOCK_FIND_PACKAGE_KF6Wallet
    INVERTED_FEATURES
        translations   KF_SKIP_PO_PROCESSING
)

if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_BSD)
    list(APPEND FEATURE_OPTIONS -DUSE_DBUS=ON -DWITH_X11=ON)
else()
    list(APPEND FEATURE_OPTIONS -DUSE_DBUS=OFF -DWITH_X11=OFF)
endif()
if(VCPKG_TARGET_IS_LINUX)
    list(APPEND FEATURE_OPTIONS -DWITH_WAYLAND=ON)
else()
    list(APPEND FEATURE_OPTIONS -DWITH_WAYLAND=OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_FIND_PACKAGE_TARGETS_GLOBAL=ON
        -DCMAKE_JOB_POOL_LINK=console # Serialize linking to avoid OOM
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6ToolsTools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_ACL=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_KF6KDED=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_KF6DocTools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_SwitcherooControl=ON
        -DKDE_INSTALL_QTPLUGINDIR=Qt6/plugins
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        CMAKE_JOB_POOL_LINK
        VCPKG_LOCK_FIND_PACKAGE_KF6Wallet
        WITH_WAYLAND
        WITH_X11
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6kio CONFIG_PATH lib/cmake/KF6KIO)
vcpkg_copy_pdbs()
set(tools kioworker)
if(NOT VCPKG_TARGET_IS_ANDROID)
    list(APPEND tools ktelnetservice6 ktrash6)
endif()
if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_BSD)
    list(APPEND tools kiod6 kioexec)
endif()
if(NOT VCPKG_BUILD_TYPE)
    # kioworker loads the worker plugins of the application, so debug applications need a debug kioworker
    vcpkg_copy_tools(
        TOOL_NAMES kioworker
        SEARCH_DIR "${CURRENT_PACKAGES_DIR}/debug/bin"
        DESTINATION "${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}"
    )
    file(WRITE "${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/qt.conf" [[
[Paths]
Prefix = ../..
Plugins = Qt6/plugins
Qml2Imports = Qt6/qml
Data = ../share
]])
endif()
vcpkg_copy_tools(TOOL_NAMES ${tools} AUTO_CLEAN)

# Without [Paths] Qt would look for the plugins next to the helpers
file(WRITE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/qt.conf" [[
[Paths]
Prefix = ../..
Plugins = Qt6/plugins
Qml2Imports = Qt6/qml
Data = share
]])

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    # The D-Bus service files start kiod6 from its build-time location
    "${CURRENT_PACKAGES_DIR}/share/dbus-1"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
