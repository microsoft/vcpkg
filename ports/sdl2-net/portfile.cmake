vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsdl-org/SDL_net
    REF 669e75b84632e2c6cc5c65974ec9e28052cb7a4e # release-2.2.0
    SHA512 180c757d704c72dc7fcc392c13942214c87b90de22e32045ec9eb6cde5da2b762516e14120d8bee52f7f4a59ad8e30d4f71e313918432ae07ef71df8e9380e4b
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSDL2NET_SAMPLES=OFF
)

vcpkg_cmake_install()

if(EXISTS "${CURRENT_PACKAGES_DIR}/cmake")
    vcpkg_cmake_config_fixup(PACKAGE_NAME SDL2_net CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME SDL2_net CONFIG_PATH lib/cmake/SDL2_net)
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/lib/pkgconfig"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
