vcpkg_download_distfile(
    ARCHIVE
    URLS "https://release.inivation.com/processing/dv-processing-${VERSION}.zip"
    FILENAME "dv-processing-${VERSION}.zip"
    SHA512 da901c15e92cdbeeccb327a63b8107d127eeeb38d1bd79e974e7476165e4c5eaffdf1197efe586b70427f133a1e270d726816cd6f04f46181a6777677bb45743
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        aeveon-decoder-include-root.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools   DVP_ENABLE_UTILITIES
)

vcpkg_find_acquire_program(PYTHON3)
x_vcpkg_get_python_packages(
    PYTHON_VERSION 3
    PYTHON_EXECUTABLE "${PYTHON3}"
    PACKAGES "jinja2"
)

vcpkg_find_acquire_program(PKGCONFIG)

set(VCPKG_BUILD_TYPE release) # no lib binaries

# Bundled Aeveon projects derive versions from git describe; keep it out of enclosing checkouts.
set(ENV{GIT_CEILING_DIRECTORIES} "${CURRENT_BUILDTREES_DIR}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE # writes to include/dv-processing/version.hpp
    OPTIONS
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        "-DAEVEON_CONTROL_CODEGEN_PYTHON=${PYTHON3}"
        ${FEATURE_OPTIONS}
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_lz4=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_zstd=ON
        -DDVP_ENABLE_TESTS=OFF
        -DDVP_ENABLE_SAMPLES=OFF
        -DDVP_ENABLE_PYTHON=OFF
        -DDVP_ENABLE_BENCHMARKS=OFF
        -DDVP_BUILD_CONFIG_VCPKG=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME aeveon_decoder CONFIG_PATH lib/cmake/aeveon_decoder DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME aeveon-control CONFIG_PATH lib/cmake/aeveon-control)

if(DVP_ENABLE_UTILITIES)
    vcpkg_copy_tools(TOOL_NAMES dv-filestat dv-imu-bias-estimation dv-list-devices dv-tcpstat AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib") # pkgconfig only, but incomplete

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/external/glarus-control/LICENSE")
