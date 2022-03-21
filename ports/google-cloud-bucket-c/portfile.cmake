vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             7332e8caa9638e0dd5863ea3cf371dff6ee7b77c
    SHA512          4000b024257b114dc3f067f3a1304fe1afb1afe80f6048c8aa15c8874db7a15643c96db63d64a9b7935cd453c3f7fb94acf073117e2a3455a9d72d937070adb0
    HEAD_REF        master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")
