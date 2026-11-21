vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PDAL/CAPI
    REF "v${VERSION}"
    SHA512 19931945234341c18ff6264d65989e23fdc78e1072b1ebda8537aa677d93cd77689d809f7ceed8e815871c750fedf248be98c14cacc890626f5921f8854567b5
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Ignore license files related to unused tests
vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.md"
        "${SOURCE_PATH}/cmake/CodeCoverage.cmake"
)
