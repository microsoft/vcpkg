vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO petiaccja/Mathter
    REF "v${VERSION}"
    SHA512 bae3460110d993996f9a5afa229b51168b30bc1ad7960c8e09fd1d74dee0b9501b2828a1127c09a6d0b9d5460d34cbf784a307257bf5c97248168547cc823974
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
