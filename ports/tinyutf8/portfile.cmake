vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DuffsDevice/tinyutf8
    REF 84d9878051cd89eb930ebfc2b686d2edfdb9db10    #version 4.4.3
    SHA512 dee248c3269c54a9bb616a08868236a049cdc629a1b668f39af59a69c672751067ce01a7f81df28ac41b500749019e543721ceae903ae9c11ea5282f2d308da4
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" TINYUTF8_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DTINYUTF8_BUILD_STATIC=${TINYUTF8_BUILD_STATIC}
        -DTINYUTF8_BUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Handle copyright
configure_file("${SOURCE_PATH}/LICENCE" "${CURRENT_PACKAGES_DIR}/share/tinyutf8/copyright" COPYONLY)

# remove unneeded files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
