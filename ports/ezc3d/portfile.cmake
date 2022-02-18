vcpkg_from_github(ARCHIVE
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pyomeca/ezc3d
    REF Release_1.4.6
    SHA512 f63da7e715c09c6a757fe923fd397c09e1cbd0a58a78b1d8fa52bd1a41230ecab2cbb17ecc3d4f66656f3234bfe4c8588164f1d4964dcce729da091e99daab2d
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
