vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libimobiledevice
    REF 0d4a7e905baeadafa098e629a5241fac6fbf7d24 # v1.3.7
    SHA512 db6369b2fa8e7b659948602ac8c4cd568bf37c0f73e58150f61f1af7000de95aa1a6a9ae546d6a37de4cb08a8059127fe5ed067351c4092c01a45350586f755a
    HEAD_REF msvc-master
)

configure_file("${CURRENT_PORT_DIR}/CMakeLists.txt" "${SOURCE_PATH}/CMakeLists.txt" COPYONLY)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
