if(WIN32)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stbrumme/hash-library
    REF hash_library_v8
    SHA512 1c428710c0c3e4d5d1114d757a5d9145ed12c7e2fbbfa51635f43a349ddb5634bdf49e8d8fdbc7576e90b319989fb85efec433bb43ddb551c2cf29a8e80ba78b
    HEAD_REF master
    PATCHES
        001-fix-macos.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "unofficial-${PORT}" CONFIG_PATH "share/unofficial-${PORT}")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
