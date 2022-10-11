if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Matroska-Org/libebml
    REF release-1.4.2
    SHA512 2A03CA1D82A41EE05CFE4DD2726CC79295FA06A4D8ECEB93FE8F41BDFF09F04897B434B49DD1F496E1C014289B14C3F3416EAB4C8B1E745652FF1AB4A620BF83
    HEAD_REF master
    PATCHES 
      include-limits.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DDISABLE_PKGCONFIG=1
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/EBML)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.LGPL" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
