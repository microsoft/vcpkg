vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            offscale/c89stringutils
    REF             375c87aaf50a945b17a76727f3314eb217897caf
    SHA512          395d942a133209daf510094814830e35daf2047c35b0ff15b17051d7095e4598fd830e0e7f763cac6929b867ff3b0c03c5350c4c3cfc68ed98b69c9c68c04be0
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_TESTS=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/c89stringutils"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
