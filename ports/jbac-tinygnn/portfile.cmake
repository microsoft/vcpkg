# TinyGNN does not annotate public symbols with __declspec(dllexport), so a
# shared-library build on Windows produces DLLs with zero exports.
# Force static linkage to avoid that and to keep the install layout simple.
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AnubhavChoudhery/TinyGNN
    REF "v${VERSION}"
    SHA512 9fa6fc5d57efc898433791d579296659511147b30454215b553b7a9ef52697dff4eb33e8e1db29f4087c698d648e20801e8d063f63f06926e61ce80a78152229
    HEAD_REF main
)

file(READ "${SOURCE_PATH}/cmake/tinygnn-config.cmake.in" _tinygnn_config)
string(REPLACE
    "find_dependency(OpenMP)"
    "if(@OpenMP_CXX_FOUND@)\n  find_dependency(OpenMP)\nendif()"
    _tinygnn_config "${_tinygnn_config}")
file(WRITE "${SOURCE_PATH}/cmake/tinygnn-config.cmake.in" "${_tinygnn_config}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openmp CMAKE_REQUIRE_FIND_PACKAGE_OpenMP
    INVERTED_FEATURES
        openmp CMAKE_DISABLE_FIND_PACKAGE_OpenMP
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DTINYGNN_BUILD_TESTS=OFF
        -DTINYGNN_BUILD_BENCHMARKS=OFF
        -DBUILD_SHARED_LIBS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME tinygnn CONFIG_PATH share/tinygnn)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
