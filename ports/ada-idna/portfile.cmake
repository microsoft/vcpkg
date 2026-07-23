vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ada-url/idna
    REF "v${VERSION}"
    SHA512 68c77140fb2590168c9d6e2745dbb8e522b9074e68d1fb2b005f60c136f5e42c7b12861e5a967996f4280b9111a9b80e2fdf979bca58d5595333f6a57e61baa5
    HEAD_REF main
    PATCHES
        fix-flags-pollution.patch
        install.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        simdutf         ADA_USE_SIMDUTF
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DADA_IDNA_BENCHMARKS=OFF
        -DBUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-ada-idna)

if(ADA_USE_SIMDUTF)
    file(READ "${CURRENT_PACKAGES_DIR}/share/unofficial-ada-idna/unofficial-ada-idna-config.cmake" cmake_config)
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/unofficial-ada-idna/unofficial-ada-idna-config.cmake"
"include(CMakeFindDependencyMacro)
find_dependency(simdutf)
${cmake_config}
")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(
    COMMENT "ada-idna is dual licensed under Apache-2.0 and MIT"
    FILE_LIST
       "${SOURCE_PATH}/LICENSE-APACHE"
       "${SOURCE_PATH}/LICENSE-MIT"
)
