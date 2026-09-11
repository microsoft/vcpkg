vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO EmbeddedSynth/sonivox
    REF "v${VERSION}"
    SHA512 2f58a8db8a0454c091301c04e05a37bdbf006a4380a8a21a4e6fff7a2607a85db502a5cbbf53511caa3135e179408306a31e5c088c6be4a32d9c6c083a301c8a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING:BOOL=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if(NOT VCPKG_TARGET_IS_ANDROID)
    vcpkg_copy_tools(TOOL_NAMES sonivoxrender AUTO_CLEAN)
endif()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "sonivox"
    CONFIG_PATH lib/cmake/sonivox
)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/man"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(
    FILE_LIST 
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/arm-wt-22k/lib_src/minimp3.h"
        "${SOURCE_PATH}/getopt_port/LICENSE.txt"
)
