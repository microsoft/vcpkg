vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simdutf/simdutf
    REF "v${VERSION}"
    SHA512 cd967640ce7a587ba7d0fbf1311bbced04beab341c03875f541179619e561773dffc8feb4b4e685ef549e7ae915b2bbd67f8b0100fd354d77ff0e068b896593f
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    "tools" SIMDUTF_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DSIMDUTF_TESTS=OFF
        -DSIMDUTF_BENCHMARKS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()
if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES sutf AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE-APACHE")
