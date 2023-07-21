vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kcmutils
    REF "v${VERSION}"
    SHA512 7c60878586f4824dc923cf9c237057bc140fb6e6cba1ea3a1deee2d95089a96f57b39026c10fbe3cc81e12ef33d6e4a6b99f4aa1b9368478885147af560cef7e
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DKDE_INSTALL_QMLDIR=qml
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5KCMUtils CONFIG_PATH lib/cmake/KF5KCMUtils)
vcpkg_copy_pdbs()

if(NOT VCPKG_TARGET_IS_WINDOWS)
    set(LIBEXEC_FOLDER "lib/libexec")
    set(LIBEXEC_SUBFOLDER "kf5/")
else()
    set(LIBEXEC_FOLDER "bin")
    set(LIBEXEC_SUBFOLDER "")
endif()

vcpkg_copy_tools(
    TOOL_NAMES kcmdesktopfilegenerator
    SEARCH_DIR "${CURRENT_PACKAGES_DIR}/${LIBEXEC_FOLDER}/${LIBEXEC_SUBFOLDER}"
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${LIBEXEC_SUBFOLDER}"
    AUTO_CLEAN
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})

