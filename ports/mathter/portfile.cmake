vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO petiaccja/Mathter
    REF "v${VERSION}"
    SHA512 e6ba527d4866a18e87be762b1188ae0342d47c3c9a5daefd0483c3b9bcbc776bb1a6f7fb6da519bfdc31b71be61ce8559825001a1634e560dca97669a459303a
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
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "Mathter")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENCE.md")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)