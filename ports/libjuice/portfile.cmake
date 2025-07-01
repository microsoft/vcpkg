vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO paullouisageneau/libjuice
    REF "v${VERSION}"
    SHA512 7364305b6768fdaef32cb7424c205e6dd11a3b8846ac52c8ce0cd66f022baae75f57293fefd2b9d80a89e3b138c82b4ef9b8b2313c2fb732db41947062ac2555
    HEAD_REF master
    PATCHES
        dependencies.diff
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
