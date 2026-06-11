vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO paullouisageneau/libjuice
    REF "v${VERSION}"
    SHA512 770b7123949a644ab8df01020abb2c8744496e1e486c91292252bb309a8c38239ae2a6c369b4eb0c028f6ac0ea78e5da09922d0ddf8446e50b4eb299cf1dabca
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
