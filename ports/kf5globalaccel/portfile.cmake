vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kglobalaccel
    REF v5.98.0
    SHA512 a8846538ced248ee537b90136bbb45cabff60088daba7a19e48d6ab63ce388353e83770cf6bad7b0c700b7404e1f4aa88f71f202dde8cdc3064456da73241050
    HEAD_REF master
)

if (VCPKG_TARGET_IS_LINUX)
    message(WARNING "${PORT} currently requires the following libraries from the system package manager:\n   libxcb-keysyms1-dev libxcb-xkb-dev libxcb-record0-dev\n\nThese can be installed on Ubuntu systems via apt-get install llibxcb-keysyms1-dev libxcb-xkb-dev libxcb-record0-dev")
endif()

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5GlobalAccel CONFIG_PATH lib/cmake/KF5GlobalAccel)
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES kglobalaccel5 AUTO_CLEAN)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})

