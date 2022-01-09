vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PDAL/CAPI
    REF v2.1.0
    SHA512 07c671f83af93594d7792d770890205aad1a44803696f9567aa25f69a277fa5c3f4e9f9f5f0210ebd59f5cf75aff1f80ce532bd7bbd536a699724ceb6e3277fd
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
        -DPDALC_ENABLE_CODE_COVERAGE:BOOL=OFF
        -DPDALC_ENABLE_DOCS:BOOL=OFF
        -DPDALC_ENABLE_TESTS:BOOL=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Git:BOOL=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Remove headers from debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Install copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
