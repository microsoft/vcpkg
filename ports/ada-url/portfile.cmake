if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "Building ${PORT} requires a C++20 compliant compiler. GCC 12 and Clang 15 are known to work.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ada-url/ada
    REF "v${VERSION}"
    SHA512 0363a75671ee98ad833211e0eb11a09048f0658cf55ec8f10a228224feb3519ac3fda4fe3cb6732137f0a0ec7e23329b12c50be32b0e68d7706a403f30620962
    HEAD_REF main
    PATCHES
        no-cpm.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools ADA_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DADA_BENCHMARKS=OFF
        -DADA_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Python3=ON
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DADA_TOOLS=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME ada CONFIG_PATH "lib/cmake/ada")
vcpkg_fixup_pkgconfig()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES adaparse AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE-APACHE" "${SOURCE_PATH}/LICENSE-MIT")
