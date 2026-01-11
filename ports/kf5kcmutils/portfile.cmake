vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kcmutils
    REF "v${VERSION}"
    SHA512 f5a22a0e662f1f3874c50b19ff770f2fa4fed53163eb7b732c8b8529424222a1b5f6908cf712c8feb6bc4984c687c51ded2cd228b01f1732d2d2c7cfba7e8f99
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
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5KCMUtils)
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
