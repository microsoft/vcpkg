vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO greg7mdp/sparsepp
    REF ${VERSION}
    SHA512 752073a80b8e7aa8c881308b2c21dc819685636599238a9b0843506be9de81c63d332af43f1f6996ba74011f4b71c64d17a5e1e7ab7ca37e57c1bf07b9144061
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

# Note: we could add: OPTIONS_DEBUG  -DDISABLE_INSTALL_HEADERS=ON
# but it's an header only package, so there's no INSTALL target. So
# we remove the duplicate headers.

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
