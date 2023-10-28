vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jtanx/libclipboard
    REF v1.1
    SHA512 763916e1be28c4d79556cb9e26bafe722e266726d26d76447d38c55c9d28a0e6f0718018636c1a16d36bb7c2567b1604a5fa8cf57163d50a313802d93a663bc4
    HEAD_REF master
    PATCHES
    	fix-libclipboard-cmake.patch
)
vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Satisfy CI.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
