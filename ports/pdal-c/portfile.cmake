vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PDAL/CAPI
    REF "v${VERSION}"
    SHA512 6fe2136831e37c2f87643b3c971a1397d8912c230e9bfde53a51ec1769bc5c2f08482395263906975c5d40dbabd32852a5a145a159cdcf2548390a0aff72a295
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
