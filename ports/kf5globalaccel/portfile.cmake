vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kglobalaccel
    REF "v${VERSION}"
    SHA512 afcf4609d6e4f3182088caccbecd71e5826c19716d2f9b22f5674a37771f082691a1b3e246b59837bbada8427d027c173d46233f1f817f2951e7a96562251fc5
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
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5GlobalAccel)
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES kglobalaccel5 AUTO_CLEAN)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
