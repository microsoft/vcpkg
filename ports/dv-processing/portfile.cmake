vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com/inivation
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dv/dv-processing
    REF b55a2e7a01ef49a861ee151bd542d4b32edfde30
    SHA512 7abf828e27af0b708c7fc3c6c78f00f9089d202a7e4a1d6c9a1f9416d2e9e394d470dc1b40ae2f491350b87f11cd17869b12ef10cd7c647e06627833f6d205f9
    HEAD_REF rel_1.7
)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com/inivation
    OUT_SOURCE_PATH CMAKEMOD_SOURCE_PATH
    REPO dv/cmakemod
    REF ec53dae89f6b037e9e640af5340d7bf67d84d278
    SHA512 e7907b1be9d85b02e1a1703cf001765119a7d07b1873148a0fbfe6945c519d85b1f9bc66b24f90d88759c2b32965304e1639f2ff136448be64fc88f81a0d4c2d
    HEAD_REF ec53dae89f6b037e9e640af5340d7bf67d84d278
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
