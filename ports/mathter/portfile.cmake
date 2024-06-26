vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO petiaccja/Mathter
    REF "v${VERSION}"
    SHA512 2fc93ab9c2e3ab5248b3d0a2db254186eeb34ad477fbce6595d6539874ad3745e095e5472144f7f0099bdca69a7de1aef8373abe6724b2fb98329847753236f7
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        simd MATHTER_ENABLE_SIMD
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMATHTER_BUILD_TESTS:BOOL=OFF
        -DMATHTER_BUILD_BENCHMARKS:BOOL=OFF
        -DMATHTER_VERSION:STRING=${VERSION}
        -DMATHTER_CMAKE_INSTALL_DIR:STRING=share/${PORT}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENCE.md")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
