vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com/inivation
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dv/dv-processing
    REF 9cd21eede0c38e079e462cdce8434fcbe2a4d037
    SHA512 fc5d0083166ff4708e6d540d437429784f9f62b7c3b7fb4631abc27ee0e6f46e60314f5fcf571c6141352571fef52a32c85a8160c951b5243910a02a281b0855
    HEAD_REF rel_1.7
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
        tools   ENABLE_UTILITIES
)

set(VCPKG_BUILD_TYPE release) # no lib binaries
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE # writes to include/dv-processing/version.hpp
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_lz4=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_zstd=ON
        -DENABLE_TESTS=OFF
        -DENABLE_SAMPLES=OFF
        -DENABLE_PYTHON=OFF
        -DBUILD_CONFIG_VCPKG=ON
)
vcpkg_cmake_install()

if(ENABLE_UTILITIES)
    vcpkg_copy_tools(TOOL_NAMES dv-filestat dv-imu-bias-estimation dv-list-devices dv-tcpstat AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib") # pkgconfig only, but incomplete

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
