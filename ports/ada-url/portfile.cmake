if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "Building ${PORT} requires a C++20 compliant compiler. GCC 12 and Clang 15 are known to work.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ada-url/ada
    REF "v${VERSION}"
    SHA512 2fc437fcb4bf18d8218b7d353cefa83bc77d484d8cab995aeaed42050c7f1f013ff0fe2ca6b5216f58c319dbedeb14c8969d59b1c794c75ee5c44789f5232d48
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

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES adaparse AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE-APACHE" "${SOURCE_PATH}/LICENSE-MIT")
