vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ryanhaining/cppitertools
    REF "v${VERSION}"
    SHA512 af7150487677ab29e77be86402997107ce897459b4e39992192a4c613e64b0d6603ac70456afee645694b262e1486e478a500d6ff854059c3015ba51bcf65263
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dcppitertools_INSTALL_CMAKE_DIR=share
)

vcpkg_cmake_install()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/share/cppitertools-config-version.cmake")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.md"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/cppitertools"
    RENAME copyright)
