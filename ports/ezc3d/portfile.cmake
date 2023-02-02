vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pyomeca/ezc3d
    REF Release_1.4.7
    SHA512 ba234be76b5d95b9527952c7e1bf67d9725fc280bf991f45e7cbd68f1aeeab7e963c8c4d928e720d02ebc02ec2b0e41f1c28036cd728ccb4c5a77c6fa81a74ad
    HEAD_REF dev
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-Dezc3d_BIN_FOLDER=bin"
        "-Dezc3d_LIB_FOLDER=lib"
        -DBUILD_EXAMPLE=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH "CMake")
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/ezc3d")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
