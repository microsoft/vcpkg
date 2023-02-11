vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kubernetes-client/c
    REF 488460fe9b75ffa61369d45b039fed085d3c817a
    SHA512  a70a524a90db4976aae05dfca4f2c6fbb255384b0b6f72a3d38434f0f92fdf73da15857d360ad3fdc0dc37164d667279f8a50cba774f064b0841abd2b33a87ea
    HEAD_REF master
    PATCHES
        001-fix-destination.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}/kubernetes
)

vcpkg_cmake_install()

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL debug)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
