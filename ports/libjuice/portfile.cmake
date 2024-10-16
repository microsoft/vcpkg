vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO paullouisageneau/libjuice
    REF "v${VERSION}"
    SHA512 694a316b7e9f33be45ace1d35a32e6a4ec74b7038c6268d0d35efcbf7a3c7abc9d2823dae789d849f37f0399d9da779a54bf6e9db5477df326aa185be92657b2
    HEAD_REF master
    PATCHES
        dependencies.diff
        library-linkage.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        nettle USE_NETTLE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DNO_TESTS=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/LibJuice)
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/juice/juice.h" "#ifndef JUICE_STATIC" "#if 0")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
