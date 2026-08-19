vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ERGO-Code/HiGHS
    REF v${VERSION}
    SHA512 0ea407784bc6c8e31c72fbcdcab201e8a7cc7debbca57504e74177658208151e90637e5fb1e0cdf1b1ae6b677e7865e77771ec025b17f8223f74d00fc6420546
    HEAD_REF master
    PATCHES
        fix-pkgconfig.patch
        fix-extras-metadata.patch
        respect-user-selected-compiler.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        extras HIPO
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DFAST_BUILD=ON
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
        -DCMAKE_REQUIRE_FIND_PACKAGE_ZLIB=ON
        -DBUILD_SHARED_EXTRAS_LIB=OFF
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_tools(TOOL_NAMES highs AUTO_CLEAN)

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/highs")
set(HIGHS_COPYRIGHT_FILES
    "${SOURCE_PATH}/LICENSE.txt"
    "${SOURCE_PATH}/THIRD_PARTY_NOTICES.md"
    "${SOURCE_PATH}/extern/cli11/CLI11.hpp"
    "${SOURCE_PATH}/extern/pdqsort/license.txt"
    "${SOURCE_PATH}/extern/zstr/LICENSE"
)
if("extras" IN_LIST FEATURES)
    # amd, metis/GKlib, and rcm are only compiled in when HIPO (the "extras" feature) is enabled.
    list(APPEND HIGHS_COPYRIGHT_FILES
        "${SOURCE_PATH}/extern/amd/License.txt"
        "${SOURCE_PATH}/extern/metis/LICENSE.txt"
        "${SOURCE_PATH}/extern/rcm/LICENSE"
    )
endif()
vcpkg_install_copyright(FILE_LIST ${HIGHS_COPYRIGHT_FILES})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
