vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO petiaccja/Mathter
    REF "v${VERSION}"
    SHA512 da4fc266a8e3bdbe388e85e5f65e7a8b54fe65264175f5348f1fbb1a5bfbcf1b2ddf4ffaecd4a1f0ac22e78fdc665a52f4929a872592ce20ce69112187d6a6e0
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMATHTER_BUILD_TESTS:BOOL=OFF
        -DMATHTER_BUILD_BENCHMARKS:BOOL=OFF
        -DMATHTER_VERSION:STRING=${VERSION}
        -DMATHTER_CMAKE_INSTALL_DIR:STRING=share/${PORT}
        -DMATHTER_ENABLE_SIMD:BOOL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENCE.md")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
