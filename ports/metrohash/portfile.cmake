vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jandrewrogers/MetroHash
    REF v1.1.3
    SHA512 02b6316e5ebf3d81465eea8a068565452be642394ddf5a53350affbbc9b9bfe1c3d182f7e8f7d49895351c48e11929e465777535e4354e01b6d0ba459e583ac5
    HEAD_REF master
)

file(COPY "${CURRENT_PORT_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
configure_file("${CURRENT_PORT_DIR}/Config.cmake.in" "${SOURCE_PATH}/cmake/Config.cmake.in" COPYONLY)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/include/metrohash128crc.h")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/metrohash.h"
        "#include \"metrohash128crc.h\""
        "//#include \"metrohash128crc.h\" // The target platform does not support _mm_crc32_u64")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
