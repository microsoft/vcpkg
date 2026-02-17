vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO petiaccja/Mathter
    REF "v${VERSION}"
    SHA512 f03578f816703c436baa052fe074a9c752b94b24ffece97a43148c9b8a680b4f89f513b79c58e9e68f9e76720d237b1eae91ea19405ff522a7e374282f4a7828
    HEAD_REF master
    PATCHES
        support-xsimd-14.patch
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
