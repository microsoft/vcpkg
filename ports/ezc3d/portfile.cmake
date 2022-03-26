vcpkg_from_github(ARCHIVE
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pyomeca/ezc3d
    REF Release_1.4.7
    SHA512 ba234be76b5d95b9527952c7e1bf67d9725fc280bf991f45e7cbd68f1aeeab7e963c8c4d928e720d02ebc02ec2b0e41f1c28036cd728ccb4c5a77c6fa81a74ad
    HEAD_REF dev
)

if(WIN32)
    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            -DBUILD_EXAMPLE=OFF
            -Dezc3d_LIB_FOLDER="lib"
            -Dezc3d_BIN_FOLDER="bin"
    )
else()
    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            -DBUILD_EXAMPLE=OFF
    )
endif()

vcpkg_cmake_install()

if(WIN32)
    vcpkg_cmake_config_fixup(CONFIG_PATH "CMake")
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake")
endif()

# # Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# # Remove duplicated include directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
