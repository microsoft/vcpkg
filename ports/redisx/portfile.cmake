vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Sigmyne/redisx
    REF "v${VERSION}"
    SHA512 e5d2a21f203da3909e2fe2d79aba3b4651c591856ee33e14df898f44aee93bfd119328ef00a554775520a2517fa35fd836b2e13785afe998d845e3d382d4026c
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tls              ENABLE_TLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_CLI=OFF
        -DENABLE_OPENMP=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/redisx" PACKAGE_NAME "redisx")

set(debug_pc "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/redisx.pc")
if(EXISTS "${debug_pc}")
    vcpkg_replace_string("${debug_pc}" "-lredisx " "-lredisxd ")
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
