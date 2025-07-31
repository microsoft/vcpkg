vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com/inivation
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dv/dv-processing
    REF "${VERSION}"
    SHA512 b714349d307fa5e164f5e9a35866a55e3ce450ebb7088ecb2501360c5f9d755d472336b48300450381fc0525fbf1d60e90aaac457e5df1f572597eacba501462
    HEAD_REF master
)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com/inivation
    OUT_SOURCE_PATH CMAKEMOD_SOURCE_PATH
    REPO dv/cmakemod
    REF d107c76b73a49a16c3ac733749152037406a515e
    SHA512 fe87530ce5fecfe5d1ccdc6a06addc652167c67c4707d9039bf2f022ced2966dc8295b8ed69c3d4154b965f0dd22f43a8830eb4f03e99ff3edfe38de759bd0d5
    HEAD_REF d107c76b73a49a16c3ac733749152037406a515e
)

file(GLOB CMAKEMOD_FILES "${CMAKEMOD_SOURCE_PATH}/*")
file(COPY ${CMAKEMOD_FILES} DESTINATION "${SOURCE_PATH}/cmake/modules")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools   DVP_ENABLE_UTILITIES
)

vcpkg_find_acquire_program(PKGCONFIG)

set(VCPKG_BUILD_TYPE release) # no lib binaries

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE # writes to include/dv-processing/version.hpp
    OPTIONS
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
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

if(DVP_ENABLE_UTILITIES)
    vcpkg_copy_tools(TOOL_NAMES dv-filestat dv-imu-bias-estimation dv-list-devices dv-tcpstat AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib") # pkgconfig only, but incomplete

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
